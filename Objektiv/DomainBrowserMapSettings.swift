//
//  DomainBrowserMapSettings.swift
//  Objektiv
//
//  Created by Dannel Albert on 12/19/17.
//  Copyright © 2017 nth loop. All rights reserved.
//

import Foundation

@objc public class DomainBrowserMapSettings: NSObject {
    @objc public var domains: [String] = []

    @objc override init() {
        super.init()
    }
    
    @objc public init(domains: [String]) {
        self.domains = domains
    }
}
