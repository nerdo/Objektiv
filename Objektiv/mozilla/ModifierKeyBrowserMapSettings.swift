//
//  ModifierKeyBrowserMapSettings.swift
//  Objektiv
//
//  Created by Dannel Albert on 12/21/17.
//  Copyright © 2017 nth loop. All rights reserved.
//

import Foundation

@objc public class ModifierKeyBrowserMapSettings: NSObject {
    @objc public var modifierFlags: NSMutableArray

    @objc override init() {
        modifierFlags = NSMutableArray()
        super.init()
    }

    @objc public init(modifierFlags: [UInt]) {
        self.modifierFlags = NSMutableArray(
            array: modifierFlags
                .filter { $0 != 0 }
                .map { NSEvent.ModifierFlags(rawValue: $0) }
        )
    }
}
