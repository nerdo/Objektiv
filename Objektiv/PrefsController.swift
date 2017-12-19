//  Converted to Swift 4 by Swiftify v1.0.6561 - https://objectivec2swift.com/
//
//  PrefsController.m
//  Objektiv
//
//  Created by Ankit Solanki on 22/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

@objc class PrefsController: NSWindowController {
    private var defaults: UserDefaults?
    private var browsers: [BrowserItem]
    private var browser: BrowserItem?
    private var imageCache = NSCache<NSString, NSImage>()

    @IBOutlet var startAtLogin: NSButton!
    @IBOutlet var autoHideIcon: NSButton!
    @IBOutlet var showNotifications: NSButton!
    @IBOutlet var hotkeyRecorder: MASShortcutView!
    @IBOutlet weak var webBrowserOutlineView: NSOutlineView!
    @IBOutlet weak var alwaysOpenTextField: NSTextField!
    @IBOutlet var hostnamesTextView: NSTextView!
    @IBOutlet weak var modifierKeysControl: ModifierKeysControl!

    @objc override init(window: NSWindow?) {
        defaults = UserDefaults.standard
        browsers = Browsers.sharedInstance().browsers as! [BrowserItem]
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        defaults = UserDefaults.standard
        browsers = Browsers.sharedInstance().browsers as! [BrowserItem]
        super.init(coder: coder)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        initUI()
    }

    // MARK: - UI methods
    @objc func showPreferences() {
        window?.makeKeyAndOrderFront(NSApp)
        NSApp.activate(ignoringOtherApps: true)
    }

    func initUI() {
        autoHideIcon.state = (defaults?.bool(forKey: PrefAutoHideIcon))! ? .on : .off
        startAtLogin.state = (defaults?.bool(forKey: PrefStartAtLogin))! ? .on : .off
        showNotifications.state = (defaults?.bool(forKey: PrefShowNotifications))! ? .on : .off
        hotkeyRecorder.associatedUserDefaultsKey = PrefHotkey
        hostnamesTextView.delegate = self
        modifierKeysControl.target = self
        modifierKeysControl.action = #selector(modifierKeyChanged(sender:))
    }

    @objc func modifierKeyChanged(sender: Any) {
        guard let browser = browser else {
            return
        }
        defaults?.set(modifierKeysControl.modifierFlags.rawValue, forKey: "\(browser.identifier):modifierKeys")
    }

    // MARK: - IBActions
    @IBAction func toggleLoginItem(_ sender: Any) {
        print("PrefsController :: toggleLoginItem")
        defaults?.set((startAtLogin.state == .on), forKey: PrefStartAtLogin)
    }

    @IBAction func toggleHideItem(_ sender: Any) {
        print("PrefsController :: toggleHideItem")
        defaults?.set((autoHideIcon.state == .on), forKey: PrefAutoHideIcon)
    }

    @IBAction func toggleShowNotifications(_ sender: Any) {
        print("PrefsController :: showNotifications")
        defaults?.set((showNotifications.state == .on), forKey: PrefShowNotifications)
    }

    @IBAction func selectedBrowserChanged(_ sender: Any) {
        browser = browsers[webBrowserOutlineView.selectedRow]
        alwaysOpenTextField.stringValue = "\(browser?.name ?? "") Hostnames"
        guard let browser = browser else {
            return
        }
        hostnamesTextView.string = defaults?.string(forKey: "\(browser.identifier):hostnames") ?? ""
        modifierKeysControl.modifierFlags = NSEvent.ModifierFlags(
            rawValue: UInt(defaults?.integer(forKey: "\(browser.identifier):modifierKeys") ?? 0)
        )
    }
}

extension PrefsController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        guard let browser = browser else {
            return
        }
        defaults?.set(hostnamesTextView.string, forKey: "\(browser.identifier):hostnames")
    }
}

extension PrefsController: NSOutlineViewDataSource {
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }

    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return browsers.count
        }
        return 0
    }

    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return browsers[index]
    }
}

extension PrefsController: NSOutlineViewDelegate {
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let browser = item as? BrowserItem,
            let cell = outlineView.makeView(withIdentifier: .init("DataCell"), owner: self) as? NSTableCellView {
            cell.textField?.stringValue = browser.name
            cell.imageView?.image = menuIcon(forAppId: browser.identifier)
            return cell
        }

        return nil
    }

    //  Converted to Swift 4 by Swiftify v1.0.6561 - https://objectivec2swift.com/
    func menuIcon(forAppId applicationIdentifier: String) -> NSImage {
        let key = NSString(string: "menu:\(applicationIdentifier)")
        var icon = imageCache.object(forKey: key)
        if icon != nil {
            return icon ?? NSImage()
        }
        icon = resizeIcon(self.icon(forAppIdentifier: applicationIdentifier))
        if let icon = icon {
            imageCache.setObject(icon, forKey: key)
        }
        return icon ?? NSImage()
    }

    //  Converted to Swift 4 by Swiftify v1.0.6561 - https://objectivec2swift.com/
    func icon(forAppIdentifier applicationIdentifier: String) -> NSImage {
        let key = NSString(string: applicationIdentifier)
        var icon = imageCache.object(forKey: key)
        if icon != nil {
            return icon ?? NSImage()
        }
        let path: String? = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: applicationIdentifier)
        icon = NSWorkspace.shared.icon(forFile: path ?? "").copy() as? NSImage
        if let icon = icon {
            imageCache.setObject(icon, forKey: key)
        }
        return icon ?? NSImage()
    }

    //  Converted to Swift 4 by Swiftify v1.0.6561 - https://objectivec2swift.com/
    func resizeIcon(_ originalIcon: NSImage) -> NSImage {
        let icon = originalIcon.copy() as? NSImage ?? NSImage()
        icon.size = CGSize(width: CGFloat(StatusBarIconSize), height: CGFloat(StatusBarIconSize))
        return icon
    }
}
