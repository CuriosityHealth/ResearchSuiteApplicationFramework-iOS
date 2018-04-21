//
//  RSMoreLayout.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/15/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSMoreLayout: RSBaseLayout, RSLayoutGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "more"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager) -> RSLayout? {
        return RSMoreLayout(json: jsonObject)
    }
    
    open override func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController {
        let viewController = RSMoreLayoutViewController(identifier: matchedRoute.route.identifier, matchedRoute: matchedRoute, parent: parent)
        return viewController
    }
    
    open override func childRoutes(routeManager: RSRouteManager, state: RSState, matchedRoute: RSMatchedRoute?, parentLayout: RSLayout?) -> [RSRoute] {
        
        guard let parent = parentLayout as? RSTabBarLayout else {
            return []
        }

        let routes = parent.hiddenTabs(state: state).compactMap({ (tab) -> RSRoute? in
            let path = RSPrefixPath(prefix: "/\(tab.identifier)")
            return RSRoute(identifier: tab.identifier, path: path, layoutIdentifier: tab.layoutIdentifier)
        })

        return routes
        
    }
    
    
    

    
}
