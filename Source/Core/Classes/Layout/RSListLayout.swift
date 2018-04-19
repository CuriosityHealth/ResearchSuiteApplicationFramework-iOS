//
//  RSListLayout.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import Gloss

open class RSListLayout: RSBaseLayout, RSLayoutGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "list"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager) -> RSLayout? {
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
