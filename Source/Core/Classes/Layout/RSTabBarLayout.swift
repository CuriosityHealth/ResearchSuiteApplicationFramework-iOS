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
    let route: JSON
    
    public init?(json: JSON) {
        guard let identifier: String = "identifier" <~~ json,
            let tabBarTitle: String = "tabBarTitle" <~~ json,
            let route: JSON = "route" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.tabBarTitle = tabBarTitle
        self.route = route
    }
    
    
}

open class RSTabBarLayout: RSBaseLayout, RSLayoutGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "tab"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager) -> RSLayout? {
        return RSTabBarLayout(json: jsonObject)
    }
    
    public let tabs: [RSTab]

    required public init?(json: JSON) {
        
        guard let tabs: [JSON] = "tabs" <~~ json else {
            return nil
        }
        
        self.tabs = tabs.compactMap { RSTab(json: $0) }
        
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
    
    open override var childRoutes: [JSON] {
        return self.tabs.map { $0.route }
    }
    

}
