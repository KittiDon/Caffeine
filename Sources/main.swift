import Cocoa
import IOKit.pwr_mgt
import ServiceManagement

// Mug: a coffee mug in the menu bar. Click it to switch between
//   filled mug  -> Mac stays awake: no idle sleep, no display sleep, no screen saver
//   empty mug   -> Mac behaves normally
// A power assertion does the work; macOS drops it automatically if the app
// quits or crashes, so the Mac can never get stuck awake.

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var assertionID: IOPMAssertionID = 0
    private var isAwake = false
    private let stateKey = "keepAwake"

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.target = self
        statusItem.button?.action = #selector(clicked)
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        // First launch: start awake and open at login.
        if UserDefaults.standard.object(forKey: stateKey) == nil {
            UserDefaults.standard.set(true, forKey: stateKey)
            try? SMAppService.mainApp.register()
        }
        setAwake(UserDefaults.standard.bool(forKey: stateKey))

        if ProcessInfo.processInfo.environment["MUG_SELFTEST"] == "1" { selfTest() }
    }

    private func setAwake(_ on: Bool) {
        if on && !isAwake {
            isAwake = IOPMAssertionCreateWithName(
                kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
                IOPMAssertionLevel(kIOPMAssertionLevelOn),
                "Mug: keeping Mac awake" as CFString, &assertionID) == kIOReturnSuccess
        } else if !on && isAwake {
            IOPMAssertionRelease(assertionID)
            isAwake = false
        }
        UserDefaults.standard.set(isAwake, forKey: stateKey)
        updateIcon()
    }

    private func updateIcon() {
        guard let button = statusItem.button else { return }
        let name = isAwake ? "mug.fill" : "mug"
        let config = NSImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        if let img = NSImage(systemSymbolName: name, accessibilityDescription: "Mug")?
            .withSymbolConfiguration(config) {
            img.isTemplate = true
            button.image = img
            button.title = ""
        } else {
            button.image = nil
            button.title = isAwake ? "☕" : "🫖"
        }
        button.toolTip = isAwake
            ? "Awake: no sleep, no screen saver. Click to allow sleep."
            : "Normal: Mac can sleep. Click to keep awake."
    }

    @objc private func clicked() {
        if NSApp.currentEvent?.type == .rightMouseUp { showMenu() } else { setAwake(!isAwake) }
    }

    private func showMenu() {
        let menu = NSMenu()
        let login = NSMenuItem(title: "Open at Login", action: #selector(toggleLogin), keyEquivalent: "")
        login.target = self
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(login)
        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit Mug", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func toggleLogin() {
        if SMAppService.mainApp.status == .enabled { try? SMAppService.mainApp.unregister() }
        else { try? SMAppService.mainApp.register() }
    }

    @objc private func quit() { NSApp.terminate(nil) }

    private func assertionCount() -> Int {
        var dict: Unmanaged<CFDictionary>?
        guard IOPMCopyAssertionsByProcess(&dict) == kIOReturnSuccess,
              let all = dict?.takeRetainedValue() as? [NSNumber: [[String: Any]]],
              let mine = all[NSNumber(value: getpid())] else { return 0 }
        return mine.count
    }

    private func selfTest() {
        let start = isAwake
        setAwake(true);  print("[selftest] on  -> awake=\(isAwake) assertions=\(assertionCount()) (expected true 1)")
        setAwake(true);  print("[selftest] on again -> assertions=\(assertionCount()) (expected 1, no leak)")
        setAwake(false); print("[selftest] off -> awake=\(isAwake) assertions=\(assertionCount()) (expected false 0)")
        setAwake(start)
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
