//
//  ModifierKeyBrowserMap.swift
//  Objektiv
//
//  Created by Dannel Albert on 12/20/17.
//  Copyright © 2017 nth loop. All rights reserved.
//

import Foundation

@objc public class ModifierKeyBrowserMap: NSObject, BrowserMappable {
    public func updatedBrowserMap(map: [String: [URL]]) -> [String: [URL]] {
        var newMap: [String : [URL]] = map
        var wasMapped = false

        if let defaultBrowserIdentifier = Browsers.sharedInstance().defaultBrowserIdentifier,
            let unprocessedUrls = map[""] {
            if newMap[defaultBrowserIdentifier] == nil {
                newMap[defaultBrowserIdentifier] = []
            }

            guard let browserItems = Browsers.browsers() as? [BrowserItem] else {
                return newMap
            }

            let currentModifierFlags = ModifierKeyListener.shared.modifierFlags
//            print("currentModifierFlags = \(currentModifierFlags)")

            for browser in browserItems {
                // This should probably go elsewhere (BrowserItem) but I don't know Objective C that well...
                browser.modifierKeyBrowserMapSettings = ModifierKeyBrowserMapSettings(
                    modifierFlags: UInt(UserDefaults.standard.integer(forKey: "\(browser.identifier):modifierKeys"))
                )

//                print("browserModifierFlags = \(browser.modifierKeyBrowserMapSettings.modifierFlags)")
                if browser.modifierKeyBrowserMapSettings.modifierFlags.rawValue != 0
                    && browser.modifierKeyBrowserMapSettings.modifierFlags == currentModifierFlags {
                    if newMap[browser.identifier] == nil {
                        newMap[browser.identifier] = []
                    }
                    newMap[browser.identifier]?.append(contentsOf: unprocessedUrls)
                    wasMapped = true
                }
            }

            if wasMapped {
                newMap[""] = nil
            }
        }

        return newMap
    }
}
