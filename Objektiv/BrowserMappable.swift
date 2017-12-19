//
//  BrowserMappable.swift
//  Objektiv
//
//  Created by Dannel Albert on 12/17/17.
//  Copyright © 2017 nth loop. All rights reserved.
//

import Foundation

@objc public protocol BrowserMappable {
    func updatedBrowserMap(map: [String: [URL]]) -> [String: [URL]]
}
