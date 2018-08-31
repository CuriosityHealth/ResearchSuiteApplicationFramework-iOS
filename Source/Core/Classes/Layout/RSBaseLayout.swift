//
//  RSBaseLayout.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSBaseLayout: RSLayout, Gloss.JSONDecodable {   
    open let identifier: String
    open let type: String
    open let onLoadActions: [JSON]
    open let onFirstAppearanceActions: [JSON]
    open let onNewStateActions: RSOnNewState = RSOnNewState()
    open var hidesNavBar = false
    open var navTitle: String?
    open var navButtonRight: RSLayoutButton?
    open var rightNavButtons: [RSLayoutButton]?
    open var onBackActions: [JSON]
    open var childRouteJSON: [JSON]
    open var element: JSON
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let type: String = "type" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        self.onLoadActions = "onLoad" <~~ json ?? []
        self.onFirstAppearanceActions = "onFirstAppearance" <~~ json ?? []
        self.hidesNavBar = "hidesNavBar" <~~ json ?? false
        self.navTitle = "navTitle" <~~ json
        self.navButtonRight = "navButtonRight" <~~ json
    
        if let rightNavButtonsJSON: [JSON] = "rightNavButtons" <~~ json {
            self.rightNavButtons = rightNavButtonsJSON.compactMap{ RSLayoutButton(json: $0) }
        }
        
//        if let onNewState: JSON = "onNewState" <~~ json {
//            self.onNewStateActions = RSOnNewState(json: onNewState) ?? RSOnNewState()
//        }
//        else {
//            self.onNewStateActions = RSOnNewState()
//        }
        
        self.onBackActions = "onBack" <~~ json ?? []
        self.childRouteJSON = "childRoutes" <~~ json ?? []
        self.element = json
    }
    
    open func childRoutes(routeManager: RSRouteManager, state: RSState, matchedRoute: RSMatchedRoute?, parentLayout: RSLayout?) -> [RSRoute] {
        return self.childRouteJSON.compactMap { routeManager.generateRoute(jsonObject: $0, state: state) }
    }
    
//    open func generateChildRoutes(state: RSState) -> [RSRoute] {
//        return []
//    }
    
    open func isEqualTo(_ object: Any) -> Bool {
        return false
    }
    
    open func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController {
        throw RSError.notImplemented
    }
    

}
