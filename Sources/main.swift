import AppKit

private enum AppConfig {
    static let displayName = "MD Save"
    static let bundleIdentifier = "app.md-save"
    static let vaultPathKey = "vaultPath"
}

struct DraftSaver {
    let vaultURL: URL

    func save(topic rawTopic: String, body rawBody: String) throws -> URL {
        let body = rawBody.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else {
            throw SaveError.emptyBody
        }

        let topic = cleanTopic(rawTopic)
        let baseName = "\(Self.datePrefix())_\(topic)"
        let targetURL = uniqueURL(baseName: baseName)
        try body.write(to: targetURL, atomically: true, encoding: .utf8)
        return targetURL
    }

    func cleanTopic(_ rawTopic: String) -> String {
        let invalid = CharacterSet(charactersIn: "/:\\*?\"<>|")
        let chars = rawTopic.unicodeScalars.map { scalar -> Character in
            if invalid.contains(scalar) || CharacterSet.whitespacesAndNewlines.contains(scalar) {
                return "_"
            }
            return Character(scalar)
        }

        var cleaned = String(chars)
        while cleaned.contains("__") {
            cleaned = cleaned.replacingOccurrences(of: "__", with: "_")
        }
        cleaned = cleaned.trimmingCharacters(in: CharacterSet(charactersIn: "_"))
        return cleaned.isEmpty ? "Untitled_Note" : cleaned
    }

    func uniqueURL(baseName: String) -> URL {
        var candidate = vaultURL.appendingPathComponent("\(baseName).md")
        var index = 2
        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = vaultURL.appendingPathComponent("\(baseName)_\(index).md")
            index += 1
        }
        return candidate
    }

    static func datePrefix() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyMMdd"
        return formatter.string(from: Date())
    }
}

enum SaveError: LocalizedError {
    case emptyBody
    case missingVault

    var errorDescription: String? {
        switch self {
        case .emptyBody:
            return "The note body is empty. Paste or type Markdown before saving."
        case .missingVault:
            return "Choose an Obsidian vault folder before saving."
        }
    }
}

final class VaultSettings {
    static let shared = VaultSettings()
    private let defaults = UserDefaults.standard

    var vaultURL: URL? {
        get {
            if let override = ProcessInfo.processInfo.environment["MDSAVE_VAULT"], !override.isEmpty {
                return URL(fileURLWithPath: override)
            }
            guard let path = defaults.string(forKey: AppConfig.vaultPathKey), !path.isEmpty else {
                return nil
            }
            return URL(fileURLWithPath: path)
        }
        set {
            defaults.set(newValue?.path, forKey: AppConfig.vaultPathKey)
        }
    }

    func isValidVault(_ url: URL?) -> Bool {
        guard let url else { return false }
        return FileManager.default.isDirectory(at: url)
    }
}

final class PlainTextView: NSTextView {
    override func paste(_ sender: Any?) {
        pasteAsPlainText(sender)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private let topicField = NSTextField()
    private let textView = PlainTextView()
    private let vaultLabel = NSTextField(labelWithString: "")
    private let settings = VaultSettings.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMenu()
        buildWindow()

        if !settings.isValidVault(settings.vaultURL) {
            chooseVault(showCancel: true)
        }

        updateVaultLabel()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func buildWindow() {
        let contentRect = NSRect(x: 0, y: 0, width: 800, height: 660)
        window = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = AppConfig.displayName
        window.minSize = NSSize(width: 620, height: 500)
        window.center()

        let root = NSView()
        root.translatesAutoresizingMaskIntoConstraints = false
        window.contentView = root

        let vaultTitle = NSTextField(labelWithString: "Obsidian vault")
        vaultTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        vaultTitle.translatesAutoresizingMaskIntoConstraints = false

        vaultLabel.lineBreakMode = .byTruncatingMiddle
        vaultLabel.textColor = .secondaryLabelColor
        vaultLabel.translatesAutoresizingMaskIntoConstraints = false

        let changeVaultButton = NSButton(title: "Choose...", target: self, action: #selector(changeVault))
        changeVaultButton.bezelStyle = .rounded
        changeVaultButton.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = NSTextField(labelWithString: "File topic")
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        topicField.placeholderString = "Do not include the date, e.g. company strategy notes"
        topicField.font = .systemFont(ofSize: 16)
        topicField.translatesAutoresizingMaskIntoConstraints = false

        let bodyLabel = NSTextField(labelWithString: "Markdown")
        bodyLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.string = clipboardText()
        moveBodyCursorToEnd()
        textView.undoManager?.removeAllActions()
        scrollView.documentView = textView

        let pasteButton = NSButton(title: "Paste Clipboard", target: self, action: #selector(pasteClipboard))
        pasteButton.bezelStyle = .rounded
        pasteButton.translatesAutoresizingMaskIntoConstraints = false

        let saveButton = NSButton(title: "Save", target: self, action: #selector(saveDraft))
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r"
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        [vaultTitle, vaultLabel, changeVaultButton, titleLabel, topicField, bodyLabel, scrollView, pasteButton, saveButton].forEach(root.addSubview)

        NSLayoutConstraint.activate([
            vaultTitle.topAnchor.constraint(equalTo: root.topAnchor, constant: 22),
            vaultTitle.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 24),

            changeVaultButton.centerYAnchor.constraint(equalTo: vaultTitle.centerYAnchor),
            changeVaultButton.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -24),

            vaultLabel.centerYAnchor.constraint(equalTo: vaultTitle.centerYAnchor),
            vaultLabel.leadingAnchor.constraint(equalTo: vaultTitle.trailingAnchor, constant: 12),
            vaultLabel.trailingAnchor.constraint(equalTo: changeVaultButton.leadingAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: vaultTitle.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -24),

            topicField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            topicField.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 24),
            topicField.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -24),
            topicField.heightAnchor.constraint(equalToConstant: 32),

            bodyLabel.topAnchor.constraint(equalTo: topicField.bottomAnchor, constant: 18),
            bodyLabel.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 24),
            bodyLabel.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -24),

            scrollView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -24),
            scrollView.bottomAnchor.constraint(equalTo: pasteButton.topAnchor, constant: -18),

            pasteButton.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 24),
            pasteButton.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -20),

            saveButton.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -24),
            saveButton.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalToConstant: 96)
        ])
    }

    private func buildMenu() {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(NSMenuItem(title: "Quit \(AppConfig.displayName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        let fileMenuItem = NSMenuItem()
        let fileMenu = NSMenu(title: "File")

        let saveItem = NSMenuItem(title: "Save", action: #selector(saveDraft), keyEquivalent: "s")
        saveItem.target = self
        fileMenu.addItem(saveItem)

        let chooseVaultItem = NSMenuItem(title: "Choose Vault...", action: #selector(changeVault), keyEquivalent: ",")
        chooseVaultItem.target = self
        fileMenu.addItem(chooseVaultItem)

        fileMenu.addItem(NSMenuItem(title: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"))
        fileMenuItem.submenu = fileMenu
        mainMenu.addItem(fileMenuItem)

        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")

        let undoItem = NSMenuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        undoItem.keyEquivalentModifierMask = [.command]
        editMenu.addItem(undoItem)

        let redoItem = NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        redoItem.keyEquivalentModifierMask = [.command, .shift]
        editMenu.addItem(redoItem)
        editMenu.addItem(.separator())

        let cutItem = NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        cutItem.keyEquivalentModifierMask = [.command]
        editMenu.addItem(cutItem)

        let copyItem = NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        copyItem.keyEquivalentModifierMask = [.command]
        editMenu.addItem(copyItem)

        let pasteItem = NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        pasteItem.keyEquivalentModifierMask = [.command]
        editMenu.addItem(pasteItem)
        editMenu.addItem(.separator())

        let selectAllItem = NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        selectAllItem.keyEquivalentModifierMask = [.command]
        editMenu.addItem(selectAllItem)

        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        NSApp.mainMenu = mainMenu
    }

    @objc private func changeVault() {
        chooseVault(showCancel: false)
    }

    private func chooseVault(showCancel: Bool) {
        let panel = NSOpenPanel()
        panel.title = "Choose your Obsidian vault"
        panel.message = "Select the folder where MD Save should create Markdown files."
        panel.prompt = "Choose Vault"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true

        let response = panel.runModal()
        if response == .OK, let url = panel.url {
            settings.vaultURL = url
            updateVaultLabel()
        } else if showCancel && !settings.isValidVault(settings.vaultURL) {
            showAlert(title: "Vault required", message: "MD Save needs a folder before it can save Markdown files.")
        }
    }

    @objc private func pasteClipboard() {
        let text = clipboardText()
        if text.isEmpty {
            showAlert(title: "Clipboard is empty", message: "Copy Markdown text first, or type directly into the Markdown area.")
            return
        }
        textView.string = text
        moveBodyCursorToEnd()
        textView.undoManager?.removeAllActions()
    }

    @objc private func saveDraft() {
        guard let vaultURL = settings.vaultURL, settings.isValidVault(vaultURL) else {
            chooseVault(showCancel: true)
            return
        }

        do {
            _ = try DraftSaver(vaultURL: vaultURL).save(topic: topicField.stringValue, body: textView.string)
            NSApp.terminate(nil)
        } catch {
            showAlert(title: "Save failed", message: error.localizedDescription)
        }
    }

    private func updateVaultLabel() {
        vaultLabel.stringValue = settings.vaultURL?.path ?? "No vault selected"
    }

    private func clipboardText() -> String {
        NSPasteboard.general.string(forType: .string) ?? ""
    }

    private func moveBodyCursorToEnd() {
        let end = (textView.string as NSString).length
        textView.setSelectedRange(NSRange(location: end, length: 0))
        textView.scrollRangeToVisible(NSRange(location: end, length: 0))
    }

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

private extension FileManager {
    func isDirectory(at url: URL) -> Bool {
        var isDir: ObjCBool = false
        return fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
    }
}

func runSelfTest() -> Int32 {
    guard let vaultPath = ProcessInfo.processInfo.environment["MDSAVE_VAULT"], !vaultPath.isEmpty else {
        fputs("MDSAVE_VAULT is required for --self-test\n", stderr)
        return 1
    }

    do {
        let saver = DraftSaver(vaultURL: URL(fileURLWithPath: vaultPath))
        let url = try saver.save(topic: "self test note", body: "# Self Test\n\nHello from MD Save.")
        print(url.path)
        return 0
    } catch {
        fputs("\(error.localizedDescription)\n", stderr)
        return 1
    }
}

if CommandLine.arguments.contains("--self-test") {
    exit(runSelfTest())
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
