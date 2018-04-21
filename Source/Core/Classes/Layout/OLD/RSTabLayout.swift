//
//  RSTabLayout.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/9/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

//open class RSTabLayout: RSLayout {
//    
//    public let items: [RSTabItem]
//    public let itemMap: [String: RSTabItem]
//    
//    
//    required public init?(json: JSON) {
//        
//        guard let items: [JSON] = "tabs" <~~ json else {
//            return nil
//        }
//        
//        self.items = items.compactMap { RSTabItem(json: $0) }
//        var itemMap: [String: RSTabItem] = [:]
//        self.items.forEach { (item) in
//            assert(itemMap[item.identifier] == nil, "items cannot have duplicate identifiers")
//            itemMap[item.identifier] = item
//        }
//        
//        self.itemMap = itemMap
//        super.init(json: json)
//    }
//
//}
