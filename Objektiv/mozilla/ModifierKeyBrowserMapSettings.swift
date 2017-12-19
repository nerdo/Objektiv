//
//  ModifierKeyBrowserMapSettings.swift
//  Objektiv
//
//  Created by Dannel Albert on 12/21/17.
//  Copyright © 2017 nth loop. All rights reserved.
//

import Foundation

@objc public class ModifierKeyBrowserMapSettings: NSObject {
    @objc public var modifierFlags: NSEvent.ModifierFlags

    @objc override init() {
        modifierFlags = NSEvent.ModifierFlags()
        super.init()
    }

    @objc public init(modifierFlags: UInt) {
        self.modifierFlags = NSEvent.ModifierFlags(rawValue: modifierFlags)
    }
}
