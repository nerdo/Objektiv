//
//  DomainBrowserMap.swift
//  Objektiv
//
//  Created by Dannel Albert on 12/18/17.
//  Copyright © 2017 nth loop. All rights reserved.
//

import Foundation

@objc public class DomainBrowserMap: NSObject, BrowserMappable {
    public func updatedBrowserMap(map: [String: [URL]]) -> [String: [URL]] {
        var newMap: [String : [URL]] = map

        if let unprocessedUrls = map[""] {
            guard let browserItems = Browsers.browsers() as? [BrowserItem] else {
                return newMap
            }

            // This should probably go elsewhere (BrowserItem) but I don't know Objective C that well...
            for browser in browserItems {
                let domains = (UserDefaults.standard.string(forKey: "\(browser.identifier):hostnames") ?? "")
                    .components(separatedBy: CharacterSet.newlines)
                    .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased() }
                    .filter { $0.count > 0 }
                browser.domainBrowserMapSettings = DomainBrowserMapSettings(domains: domains)
            }

            for url in unprocessedUrls {
                if let lowercaseHost = url.host?.lowercased() {
                    let browserItem =
                        browserItems.first(where: {
                            $0.domainBrowserMapSettings.domains.contains(lowercaseHost)
                                || $0.domainBrowserMapSettings.domains.filter {
                                    lowercaseHost.hasSuffix(".\($0)")
                                }.count > 0
                        })

                    if let browserItem = browserItem {
                        if newMap[browserItem.identifier] == nil {
                            newMap[browserItem.identifier] = []
                        }
                        newMap[browserItem.identifier]?.append(url)

                        if let index = newMap[""]?.index(of: url) {
                            newMap[""]?.remove(at: index)
                        }
                    }
                }
            }
        }

        return newMap
    }
}
