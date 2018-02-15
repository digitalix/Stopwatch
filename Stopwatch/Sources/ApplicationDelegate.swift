
import Cocoa

final class ApplicationDelegate: NSObject {

    private let statusItem = NSStatusBar.system.statusItem(withLength: 80.0)

    private var date: Date? {
        didSet {
            self.timer = self.date.map { _ in
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateStatusItem(_:)), userInfo: nil, repeats: true)
            }
        }
    }

    private var timer: Timer? {
        willSet {
            self.timer?.invalidate()
        }
        didSet {
            self.updateStatusItem(nil)
        }
    }

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

extension ApplicationDelegate: NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.updateStatusItem(nil)
    }
}

extension ApplicationDelegate {

    @objc private func startTimer(_: Any?) {
        self.date = Date()
    }

    @objc private func stopTimer(_: Any?) {
        self.timer = nil
    }

    @objc private func resetTimer(_: Any?) {
        self.date = nil
    }
}

extension ApplicationDelegate {

    @objc private func updateStatusItem(_: Any?) {

        // Because of this dirty, dirty hack, the stopwatch can only count up to 24 hours
        let date = Calendar.current.startOfDay(for: Date()) + Date().timeIntervalSince(self.date ?? Date())

        self.statusItem.button!.font = NSFont.monospacedDigitSystemFont(ofSize: 14.0, weight: .regular)
        self.statusItem.button!.title = self.formatter.string(from: date)

        let menu = NSMenu(title: "")
        if let _ = self.timer {
            menu.addItem(withTitle: NSLocalizedString("Stop", comment: ""), action: #selector(stopTimer(_:)), keyEquivalent: "")
        }
        else {
            menu.addItem(withTitle: NSLocalizedString("Start", comment: ""), action: #selector(startTimer(_:)), keyEquivalent: "")
            if let _ = self.date {
                menu.addItem(withTitle: NSLocalizedString("Reset", comment: ""), action: #selector(resetTimer(_:)), keyEquivalent: "")
            }
        }
        menu.addItem(.separator())
        menu.addItem(withTitle: NSLocalizedString("Quit", comment: ""), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")

        self.statusItem.menu = menu
    }
}
