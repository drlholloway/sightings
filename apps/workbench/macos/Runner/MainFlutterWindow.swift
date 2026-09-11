import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    var windowFrame = self.frame
    // Developer hook for the screenshot tour: SIGHTINGS_WINDOW=1280x840.
    if let spec = ProcessInfo.processInfo.environment["SIGHTINGS_WINDOW"] {
      let parts = spec.split(separator: "x").compactMap { Double($0) }
      if parts.count == 2 {
        windowFrame.size = NSSize(width: parts[0], height: parts[1])
      }
    }
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
