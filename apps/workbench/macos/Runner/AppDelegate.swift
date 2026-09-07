import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  /// Tip link shown in the About panel; keep in sync with `tipUrl` in
  /// lib/features/settings/settings_screen.dart.
  private let tipURL = "https://buymeacoffee.com/drlholloway"
  private let sourceURL = "https://github.com/drlholloway/sightings"

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    // Point the "About Sightings" menu item at our panel with credits.
    if let appMenu = NSApp.mainMenu?.items.first?.submenu,
       let about = appMenu.items.first(where: {
         $0.action == #selector(NSApplication.orderFrontStandardAboutPanel(_:))
       }) {
      about.target = self
      about.action = #selector(showAboutPanel(_:))
    }
  }

  @objc func showAboutPanel(_ sender: Any?) {
    let credits = NSMutableAttributedString()
    let body: [NSAttributedString.Key: Any] = [
      .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
      .foregroundColor: NSColor.labelColor,
    ]
    func line(_ s: String) { credits.append(NSAttributedString(string: s + "\n", attributes: body)) }
    func link(_ label: String, _ url: String) {
      var attrs = body
      attrs[.link] = URL(string: url)!
      credits.append(NSAttributedString(string: label, attributes: attrs))
      credits.append(NSAttributedString(string: "\n", attributes: body))
    }
    line("Companion for the Peak Atlas DCA75 semiconductor analyzer.")
    line("Free on every platform. Source under PolyForm Shield 1.0.0.")
    line("")
    link("Buy me a coffee ☕", tipURL)
    link("Source and releases on GitHub", sourceURL)
    line("")
    line("Not affiliated with Peak Electronic Design Ltd.")
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    credits.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: credits.length))

    NSApp.orderFrontStandardAboutPanel(options: [.credits: credits])
    NSApp.activate(ignoringOtherApps: true)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
