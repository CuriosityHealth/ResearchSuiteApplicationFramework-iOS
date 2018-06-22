//
//  RSDashboardLayout.swift
//  Pods
//
//  Created by James Kizer on 6/5/18.
//

import UIKit
import Gloss

open class RSDashboardLayout: RSBaseLayout, RSLayoutGenerator  {
    
    public static func supportsType(type: String) -> Bool {
        return type == "dashboard"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager, state: RSState) -> RSLayout? {
        return RSDashboardLayout(json: jsonObject)
    }
    
    public let items: [RSDashboardListItem]
    public let monitoredValues: [JSON]
    
    required public init?(json: JSON) {
        
        guard let itemsJSON: [JSON] = "items" <~~ json else {
            return nil
        }
        
        self.items = itemsJSON.compactMap({ RSDashboardListItem(json: $0) })
        self.monitoredValues = "monitoredValues" <~~ json ?? []
        
        super.init(json: json)
    }
    
    open override func isEqualTo(_ object: Any) -> Bool {
        
        assertionFailure()
        return false
        
    }
    
    open override func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController {
        
        let bundle = Bundle(for: RSCalendarLayout.self)
        let storyboard: UIStoryboard = UIStoryboard(name: "RSViewControllers", bundle: bundle)
        
        guard let layoutVC = storyboard.instantiateViewController(withIdentifier: "dashboardLayoutViewController") as? RSDashboardLayoutViewController else {
            throw RSLayoutError.cannotInstantiateLayout(layoutIdentifier: self.identifier)
        }
        
        layoutVC.matchedRoute = matchedRoute
        layoutVC.parentLayoutViewController = parent
        
        return layoutVC
        
    }
    
}
