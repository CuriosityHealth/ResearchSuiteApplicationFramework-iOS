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
    public let presentedRouteJSON: [JSON]

    required public init?(json: JSON) {
        
        guard let tabs: [JSON] = "tabs" <~~ json else {
            return nil
        }
        
        self.tabs = tabs.compactMap { RSTab(json: $0) }
        self.tabOrderKey = "tabOrderKey" <~~ json
        
        self.presentedRouteJSON = "presentedRoutes" <~~ json ?? []
        
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
    
    open func visibleTabs(sortedTabs: [RSTab]) -> [RSTab] {
        
        if sortedTabs.count > 5 {
            return Array(sortedTabs.prefix(4))
        }
        else {
            return sortedTabs
        }
    }
    
    open func hiddenTabs(sortedTabs: [RSTab]) -> [RSTab] {
        
        if sortedTabs.count > 5 {
            return Array(sortedTabs.dropFirst(4))
        }
        else {
            return []
        }
        
    }
    
    open func hiddenTabs(state: RSState) -> [RSTab] {
        
        return self.hiddenTabs(sortedTabs: self.sortedTabs(state: state))
        
    }
    
    open override func childRoutes(routeManager: RSRouteManager, state: RSState, matchedRoute: RSMatchedRoute?, parentLayout: RSLayout?) -> [RSRoute] {
        
        //only a maximum of 4 tabs are visible at a time
        //If more tha 4 tabs are included, a more button is shown
        
        let sortedTabs = self.sortedTabs(state: state)
        
        let visibleTabs = self.visibleTabs(sortedTabs: sortedTabs)
        
        let tabRoutes: [RSRoute] = {
            
            let visibleTabRoutes = visibleTabs.compactMap({ (tab) -> RSRoute? in
                let path = RSPrefixPath(prefix: "/\(tab.identifier)")
                return RSRoute(identifier: tab.identifier, path: path, layoutIdentifier: tab.layoutIdentifier)
            })
            
            let hiddenTabs = self.hiddenTabs(sortedTabs: sortedTabs)
            
            if hiddenTabs.count > 0 {
                
                let moreTabRoute = RSRoute(identifier: "more", path: RSPrefixPath(prefix: "/more"), layoutIdentifier: "more")
                
                let hiddenTabRoutes = hiddenTabs.compactMap({ (tab) -> RSRoute? in
                    let path = RSPrefixPath(prefix: "/\(tab.identifier)")
                    let rediretPath = "\(matchedRoute!.match.path)/more/\(tab.identifier)"
                    return RSRedirectRoute(identifier: tab.identifier, path: path, redirectPath: rediretPath)
                })
                
                return visibleTabRoutes + [moreTabRoute] + hiddenTabRoutes
                
            }
            else {
                
                return visibleTabRoutes
                
            }
            
        }()
        
        let presentationRoutes = self.presentedRouteJSON.compactMap { routeManager.generateRoute(jsonObject: $0, state: state) }
        
        
        return tabRoutes + presentationRoutes
        
        
    }
    
    
    
}
