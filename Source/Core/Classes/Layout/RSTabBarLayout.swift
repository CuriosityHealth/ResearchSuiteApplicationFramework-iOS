//
//  RSTabBarLayout.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/15/18.
//

import UIKit
import Gloss

public struct RSTab: JSONDecodable {
    
    let identifier: String
    let tabBarTitle: String
    let layoutIdentifier: String
    public init?(json: JSON) {
        guard let identifier: String = "identifier" <~~ json,
            let tabBarTitle: String = "tabBarTitle" <~~ json,
            let layoutIdentifier: String = "layout" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.tabBarTitle = tabBarTitle
        self.layoutIdentifier = layoutIdentifier
    }
    
    
}

open class RSTabBarLayout: RSBaseLayout, RSLayoutGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "tab"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager) -> RSLayout? {
        return RSTabBarLayout(json: jsonObject)
    }
    
    public let tabOrderKey: String?
    public let tabs: [RSTab]

    required public init?(json: JSON) {
        
        guard let tabs: [JSON] = "tabs" <~~ json else {
            return nil
        }
        
        self.tabs = tabs.compactMap { RSTab(json: $0) }
        self.tabOrderKey = "tabOrderKey" <~~ json
        
        super.init(json: json)
    }
    
    open override func isEqualTo(_ object: Any) -> Bool {
        
        assertionFailure()
        return false
        
    }
    
    open override func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController {
        let viewController = RSTabBarLayoutViewController(identifier: matchedRoute.route.identifier, matchedRoute: matchedRoute, parent: parent)
        return viewController
    }

    open func sortedTabs(state: RSState) -> [RSTab] {
        
        if let tabOrderKey = self.tabOrderKey,
            let tabOrder = RSStateSelectors.getValueInCombinedState(state, for: tabOrderKey) as? [String] {
            return self.tabs.sorted { (a, b) -> Bool in
                
                guard let indexOfA = tabOrder.index(of: a.identifier),
                    let indexOfB = tabOrder.index(of: b.identifier) else {
                        return true
                }
                
                return indexOfA < indexOfB
            }
        }
        else {
            return self.tabs
        }
    }
    
    open func visibleTabs(state: RSState) -> [RSTab] {
        return Array(self.sortedTabs(state: state).prefix(4))
    }
    
    open func hiddenTabs(state: RSState) -> [RSTab] {
        return Array(self.sortedTabs(state: state).dropFirst(4))
    }
    
    open override func childRoutes(routeManager: RSRouteManager, state: RSState, matchedRoute: RSMatchedRoute?, parentLayout: RSLayout?) -> [RSRoute] {
        
        //only a maximum of 4 tabs are visible at a time
        //If more tha 4 tabs are included, a more button is shown
        
        let visibleRoutes = self.visibleTabs(state: state).compactMap({ (tab) -> RSRoute? in
            let path = RSPrefixPath(prefix: "/\(tab.identifier)")
            return RSRoute(identifier: tab.identifier, path: path, layoutIdentifier: tab.layoutIdentifier)
        })
        
        let moreRoute = RSRoute(identifier: "more", path: RSPrefixPath(prefix: "/more"), layoutIdentifier: "more")
        
        let hiddenRoutes = self.hiddenTabs(state: state).compactMap({ (tab) -> RSRoute? in
            let path = RSPrefixPath(prefix: "/\(tab.identifier)")
            let rediretPath = "\(matchedRoute!.match.path)/more/\(tab.identifier)"
            return RSRedirectRoute(identifier: tab.identifier, path: path, redirectPath: rediretPath)
        })
        
        return visibleRoutes + [moreRoute] + hiddenRoutes
        
    }
    
    
    
}
