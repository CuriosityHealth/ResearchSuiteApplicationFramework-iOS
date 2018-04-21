//
//  RSListLayout0ld.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/4/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

//open class RSListLayout: RSLayout {
//    
//    public let items: [RSListItem]
//    public let itemMap: [String: RSListItem]
//    public let monitoredValues: [JSON]
//
//    required public init?(json: JSON) {
//        
//        guard let items: [JSON] = "items" <~~ json else {
//                return nil
//        }
//        
//        self.items = items.compactMap { RSListItem(json: $0) }
//        var itemMap: [String: RSListItem] = [:]
//        self.items.forEach { (item) in
//            assert(itemMap[item.identifier] == nil, "items cannot have duplicate identifiers")
//            itemMap[item.identifier] = item
//        }
//        
//        self.itemMap = itemMap
//        self.monitoredValues = "monitoredValues" <~~ json ?? []
//        super.init(json: json)
//    }
//
//}
