//
//  RSListLayout.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSListLayout: RSBaseLayout, RSLayoutGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "list"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager, state: RSState) -> RSLayout? {
        return RSListLayout(json: jsonObject)
    }

    public let items: [RSListItem]
    public let itemMap: [String: RSListItem]
    public let monitoredValues: [JSON]
    
    required public init?(json: JSON) {
        
        guard let items: [JSON] = "items" <~~ json else {
            return nil
        }
        
        self.items = items.compactMap { RSListItem(json: $0) }
        var itemMap: [String: RSListItem] = [:]
        self.items.forEach { (item) in
            assert(itemMap[item.identifier] == nil, "items cannot have duplicate identifiers")
            itemMap[item.identifier] = item
        }
        
        self.itemMap = itemMap
        self.monitoredValues = "monitoredValues" <~~ json ?? []
        super.init(json: json)
    }
    
    open override func isEqualTo(_ object: Any) -> Bool {
        
        assertionFailure()
        return false
        
    }
    
    open override func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController {
        
        let bundle = Bundle(for: RSListLayout.self)
        let storyboard: UIStoryboard = UIStoryboard(name: "RSViewControllers", bundle: bundle)
        
        guard let listLayoutVC = storyboard.instantiateViewController(withIdentifier: "listLayoutViewController") as? RSLayoutTableViewController else {
            throw RSLayoutError.cannotInstantiateLayout(layoutIdentifier: self.identifier)
        }
        
        listLayoutVC.matchedRoute = matchedRoute
        listLayoutVC.parentLayoutViewController = parent
        
        return listLayoutVC
        
    }
    
}
