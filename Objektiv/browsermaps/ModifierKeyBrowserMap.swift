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

        if let unprocessedUrls = map[""] {
            guard let browserItems = Browsers.browsers() as? [BrowserItem] else {
                return newMap
            }

            let currentModifierFlags = ModifierKeyListener.shared.modifierFlags
//            print("currentModifierFlags = \(currentModifierFlags)")

            for browser in browserItems {
                guard let modifierKeySets = UserDefaults.standard.array(forKey: "\(browser.identifier):modifierKeys") as? [UInt] else {
                    continue
                }

                browser.modifierKeyBrowserMapSettings = ModifierKeyBrowserMapSettings(modifierFlags: modifierKeySets)
                for modifierKeys in browser.modifierKeyBrowserMapSettings.modifierFlags {
                    guard let modifierFlags = modifierKeys as? NSEvent.ModifierFlags else {
                        continue
                    }

    //                print("browserModifierFlags = \(modifierFlags)")
                    if modifierFlags.rawValue != 0 && modifierFlags == currentModifierFlags {
                        if newMap[browser.identifier] == nil {
                            newMap[browser.identifier] = []
                        }
                        newMap[browser.identifier]?.append(contentsOf: unprocessedUrls)
                        wasMapped = true
                        break
                    }
                }
            }

            if wasMapped {
                newMap[""] = nil
            }
        }

        return newMap
    }
}
