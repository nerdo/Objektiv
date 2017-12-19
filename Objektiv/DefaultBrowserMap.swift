//
//  DefaultBrowserMap.swift
//  Objektiv
//
//  Created by Dannel Albert on 12/17/17.
//  Copyright © 2017 nth loop. All rights reserved.
//

import Foundation

@objc public class DefaultBrowserMap: NSObject, BrowserMappable {
    public func updatedBrowserMap(map: [String: [URL]]) -> [String: [URL]] {
        var newMap: [String : [URL]] = map

        if let defaultBrowserIdentifier = Browsers.sharedInstance().defaultBrowserIdentifier,
            let unprocessedUrls = map[""] {
            if newMap[defaultBrowserIdentifier] == nil {
                newMap[defaultBrowserIdentifier] = []
            }

            newMap[defaultBrowserIdentifier]?.append(contentsOf: unprocessedUrls)
            newMap[""] = nil
        }

        return newMap
    }
}
