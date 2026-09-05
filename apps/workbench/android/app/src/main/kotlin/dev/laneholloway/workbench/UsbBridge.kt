package dev.laneholloway.workbench

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbInterface
import android.hardware.usb.UsbManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Minimal USB bulk bridge for the DCA75. Methods: list, hasPermission,
 * requestPermission, open, exchange, close. Events: attached, detached,
 * permission.
 */
class UsbBridge(private val context: Context, messenger: BinaryMessenger) {
    companion object {
        const val VID = 0x04D8
        const val PID = 0xF8CA
        const val ACTION_PERMISSION = "dev.laneholloway.workbench.USB_PERMISSION"
    }

    private val manager = context.getSystemService(Context.USB_SERVICE) as UsbManager
    private val executor = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null

    private var device: UsbDevice? = null
    private var connection: UsbDeviceConnection? = null
    private var iface: UsbInterface? = null
    private var epIn: UsbEndpoint? = null
    private var epOut: UsbEndpoint? = null

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context, intent: Intent) {
            val dev: UsbDevice? = if (Build.VERSION.SDK_INT >= 33)
                intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
            else @Suppress("DEPRECATION") intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
            when (intent.action) {
                UsbManager.ACTION_USB_DEVICE_ATTACHED -> dev?.let { emit("attached", it) }
                UsbManager.ACTION_USB_DEVICE_DETACHED -> dev?.let {
                    if (device?.deviceName == it.deviceName) closeInternal()
                    emit("detached", it)
                }
                ACTION_PERMISSION -> dev?.let {
                    val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
                    sink?.success(mapOf("event" to "permission", "id" to it.deviceName, "granted" to granted))
                }
            }
        }
    }

    init {
        MethodChannel(messenger, "dca75/usb").setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "list" -> result.success(manager.deviceList.values.map { describe(it) })
                    "hasPermission" -> result.success(find(call.argument("id"))?.let { manager.hasPermission(it) } ?: false)
                    "requestPermission" -> {
                        val d = find(call.argument("id")) ?: throw UsbError("notFound", "device not present")
                        val flags = if (Build.VERSION.SDK_INT >= 31) PendingIntent.FLAG_MUTABLE else 0
                        val pi = PendingIntent.getBroadcast(context, 0, Intent(ACTION_PERMISSION).setPackage(context.packageName), flags)
                        manager.requestPermission(d, pi)
                        result.success(null)
                    }
                    "open" -> { open(find(call.argument("id")) ?: throw UsbError("notFound", "device not present")); result.success(null) }
                    "exchange" -> {
                        val data = call.argument<ByteArray>("data") ?: throw UsbError("io", "no data")
                        val timeout = call.argument<Int>("timeoutMs") ?: 2500
                        executor.execute {
                            try {
                                val r = exchange(data, timeout)
                                main.post { result.success(r) }
                            } catch (e: UsbError) {
                                main.post { result.error(e.code, e.message, null) }
                            } catch (e: Exception) {
                                main.post { result.error("io", e.toString(), null) }
                            }
                        }
                    }
                    "close" -> { closeInternal(); result.success(null) }
                    else -> result.notImplemented()
                }
            } catch (e: UsbError) {
                result.error(e.code, e.message, null)
            } catch (e: Exception) {
                result.error("io", e.toString(), null)
            }
        }
        EventChannel(messenger, "dca75/usb_events").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, events: EventChannel.EventSink?) { sink = events }
            override fun onCancel(args: Any?) { sink = null }
        })
        val filter = IntentFilter().apply {
            addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
            addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
            addAction(ACTION_PERMISSION)
        }
        if (Build.VERSION.SDK_INT >= 33) context.registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
        else context.registerReceiver(receiver, filter)
    }

    fun dispose() {
        closeInternal()
        try { context.unregisterReceiver(receiver) } catch (_: Exception) {}
        executor.shutdown()
    }

    private fun emit(event: String, d: UsbDevice) {
        sink?.success(describe(d) + ("event" to event))
    }

    private fun find(id: String?): UsbDevice? = manager.deviceList.values.firstOrNull { it.deviceName == id }

    private fun describe(d: UsbDevice): Map<String, Any?> {
        val perm = manager.hasPermission(d)
        return mapOf(
            "id" to d.deviceName,
            "vid" to d.vendorId,
            "pid" to d.productId,
            "product" to d.productName,
            "serial" to (if (perm) try { d.serialNumber } catch (_: Exception) { null } else null),
            "hasPermission" to perm,
        )
    }

    private fun open(d: UsbDevice) {
        closeInternal()
        if (!manager.hasPermission(d)) throw UsbError("access", "USB permission not granted")
        var found: Triple<UsbInterface, UsbEndpoint, UsbEndpoint>? = null
        for (i in 0 until d.interfaceCount) {
            val itf = d.getInterface(i)
            var bin: UsbEndpoint? = null
            var bout: UsbEndpoint? = null
            for (e in 0 until itf.endpointCount) {
                val ep = itf.getEndpoint(e)
                if (ep.type != UsbConstants.USB_ENDPOINT_XFER_BULK) continue
                if (ep.direction == UsbConstants.USB_DIR_IN) { if (bin == null) bin = ep } else { if (bout == null) bout = ep }
            }
            if (bin != null && bout != null) { found = Triple(itf, bin, bout); break }
        }
        val (itf, bin, bout) = found ?: throw UsbError("notFound", "no bulk endpoint pair found")
        val conn = manager.openDevice(d) ?: throw UsbError("access", "openDevice returned null")
        if (!conn.claimInterface(itf, true)) { conn.close(); throw UsbError("busy", "claimInterface failed") }
        device = d; connection = conn; iface = itf; epIn = bin; epOut = bout
    }

    private fun exchange(out: ByteArray, timeoutMs: Int): ByteArray {
        val conn = connection ?: throw UsbError("notOpen", "not open")
        val w = conn.bulkTransfer(epOut, out, out.size, timeoutMs)
        if (w < 0) throw failure("bulk out")
        val buf = ByteArray(64)
        val r = conn.bulkTransfer(epIn, buf, buf.size, timeoutMs)
        if (r < 0) throw failure("bulk in")
        return buf.copyOf(r)
    }

    private fun failure(what: String): UsbError {
        val stillThere = device?.let { manager.deviceList.containsKey(it.deviceName) } ?: false
        return if (!stillThere) UsbError("disconnected", "$what: device gone") else UsbError("timeout", "$what: transfer failed or timed out")
    }

    private fun closeInternal() {
        try { iface?.let { connection?.releaseInterface(it) } } catch (_: Exception) {}
        try { connection?.close() } catch (_: Exception) {}
        connection = null; iface = null; epIn = null; epOut = null; device = null
    }

    class UsbError(val code: String, message: String) : Exception(message)
}
