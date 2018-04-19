//
//  RSBaseLayout.swift
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

open class RSBaseLayout: RSLayout, Gloss.JSONDecodable {
    
    open let identifier: String
    open let type: String
    open let onLoadActions: [JSON]
    open let onFirstAppearanceActions: [JSON]
    open var navTitle: String?
    open var navButtonRight: RSLayoutButton?
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
        self.navTitle = "navTitle" <~~ json
        self.navButtonRight = "navButtonRight" <~~ json
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
