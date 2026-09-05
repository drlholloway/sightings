# Phase 8 — Future: iOS viewer and cross‑device sync (out of initial scope)

Recorded here so earlier phases keep the doors open.

## iOS / iPadOS
- **Live USB is not available on iPhone** for third‑party vendor‑class devices, and on iPad it
  requires an M‑series iPad, a DriverKit system extension, and a per‑vendor‑ID entitlement
  granted by Apple. Not worth pursuing for a personal tool.
- Instead: the same Flutter app built for iOS with the transport stubbed (`UnsupportedTransport`)
  becomes a **viewer**: open a `.sqlite` backup (Files app, AirDrop, iCloud Drive), browse
  history, parts, bins, and saved sweeps; tag/annotate; export CSV.
- Requirements this places on earlier phases (already in the plan): the SQLite file is the
  interchange format; annotations are separate tables; `db_uuid` in `schema_meta`; the UI
  works with `DeviceStatus.disconnected` permanently; no screen assumes a device is present.

## Sync
- Phase 4's merge‑import (dedupe on device serial + taken_at + raw frame; tags merge by
  latest `updated_at`) is the minimal sync: export from one device, import on another.
- Later options, in order of effort: iCloud Drive / a synced folder holding the DB file with
  a change‑log table; or a small self‑hosted sync (e.g. append‑only readings pushed over HTTPS).
  Avoid anything that forces a server before it is needed.

## Windows
- The transport interface plus `quick_usb`/libusb makes Windows a packaging exercise (WinUSB
  driver install via the Peak INF or Zadig). Not planned, but nothing blocks it.
