//
//  RSListLayout.swift
//  Pods
//
//  Created by James Kizer on 7/4/17.
//
//

import UIKit
import Gloss

open class RSListLayout: RSLayout {
    
    public let items: [RSListItem]
    public let itemMap: [String: RSListItem]
    
    
    required public init?(json: JSON) {
        
        guard let items: [JSON] = "items" <~~ json else {
                return nil
        }
        
        self.items = items.flatMap { RSListItem(json: $0) }
        var itemMap: [String: RSListItem] = [:]
        self.items.forEach { (item) in
            assert(itemMap[item.identifier] == nil, "items cannot have duplicate identifiers")
            itemMap[item.identifier] = item
        }
        
        self.itemMap = itemMap
        super.init(json: json)
    }

}
