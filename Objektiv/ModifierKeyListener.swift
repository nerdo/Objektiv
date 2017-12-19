//
//  ModifierKeyListener.swift
//  Objektiv
//
//  Created by Dannel Albert on 12/20/17.
//  Copyright © 2017 nth loop. All rights reserved.
//

import AppKit

@objc open class ModifierKeyListener: NSObject {
    @objc open static let shared = ModifierKeyListener()

    @objc open private(set) var modifierFlags = NSEvent.ModifierFlags()

    @objc open var capsLock: Bool {
        return modifierFlags.contains(.capsLock)
    }

    @objc open var shift: Bool {
        return modifierFlags.contains(.shift)
    }

    @objc open var control: Bool {
        return modifierFlags.contains(.control)
    }

    @objc open var option: Bool {
        return modifierFlags.contains(.option)
    }

    @objc open var command: Bool {
        return modifierFlags.contains(.command)
    }

    @objc open var help: Bool {
        return modifierFlags.contains(.help)
    }

    @objc open var function: Bool {
        return modifierFlags.contains(.function)
    }

    @objc override private init() {
        super.init()

        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) {
            self.modifierFlags = $0.modifierFlags.intersection(.deviceIndependentFlagsMask)

            #if DEBUG
                var keyNames: [String] = []

                if self.capsLock {
                    keyNames.append("⇪")
                }

                if self.shift {
                    keyNames.append("⇧")
                }

                if self.control {
                    keyNames.append("⌃")
                }

                if self.option {
                    keyNames.append("⌥")
                }

                if self.command {
                    keyNames.append("⌘")
                }

                if self.help {
                    keyNames.append("help")
                }

                if self.function {
                    keyNames.append("fn")
                }

                print("modifier keys: \(keyNames)")
            #endif
        }
    }
}
