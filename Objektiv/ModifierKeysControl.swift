//
//  ModifierKeysControl.swift
//  Objektiv
//
//  Created by Dannel Albert on 12/21/17.
//  Copyright © 2017 nth loop. All rights reserved.
//

import AppKit

open class ModifierKeysControl: NSSegmentedControl {
    open var modifierFlags: NSEvent.ModifierFlags {
        get {
            var flags = NSEvent.ModifierFlags()

            if isSelected(forSegment: 0) {
                flags.insert(.function)
            }
            if isSelected(forSegment: 1) {
                flags.insert(.shift)
            }
            if isSelected(forSegment: 2) {
                flags.insert(.control)
            }
            if isSelected(forSegment: 3) {
                flags.insert(.option)
            }
            if isSelected(forSegment: 4) {
                flags.insert(.command)
            }

            return flags
        }

        set {
            setSelected(newValue.contains(.function), forSegment: 0)
            setSelected(newValue.contains(.shift), forSegment: 1)
            setSelected(newValue.contains(.control), forSegment: 2)
            setSelected(newValue.contains(.option), forSegment: 3)
            setSelected(newValue.contains(.command), forSegment: 4)
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        segmentCount = 5

        trackingMode = .selectAny

        setLabel("fn", forSegment: 0)
        setLabel("⇧", forSegment: 1)
        setLabel("⌃", forSegment: 2)
        setLabel("⌥", forSegment: 3)
        setLabel("⌘", forSegment: 4)

        modifierFlags = NSEvent.ModifierFlags()
    }

    open override func layout() {
//        let segmentWidth = bounds.width / 5.0
        let segmentWidth = CGFloat(0.0)
        setWidth(segmentWidth, forSegment: 0)
        setWidth(segmentWidth, forSegment: 1)
        setWidth(segmentWidth, forSegment: 2)
        setWidth(segmentWidth, forSegment: 3)
        setWidth(segmentWidth, forSegment: 4)
        super.layout()
    }
}
