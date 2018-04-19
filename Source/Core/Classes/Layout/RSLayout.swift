//
//  RSLayout.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
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

public enum RSLayoutError: Error {
    case cannotInstantiateLayout(layoutIdentifier: String)
    case noMatchingLayout(routeIdentifier: String, layoutIdentifier: String)
}

//A Layout is more or less a template for a view controller
public protocol RSLayout: RSIsEqual {
    var identifier: String { get }
    var type: String { get }
    //when loaded into memory - analogous to viewDidLoad
    var onLoadActions: [JSON] { get }
    //when the layout is on the tap of the stack for the FIRST time in its lifecycle
    var onFirstAppearanceActions: [JSON] { get }
    
    var navTitle: String? { get }
    var navButtonRight: RSLayoutButton? { get }
    var onBackActions: [JSON] { get }
//    var childRoutes: [JSON] { get }
    func childRoutes(routeManager: RSRouteManager, state: RSState, matchedRoute: RSMatchedRoute?, parentLayout: RSLayout?) -> [RSRoute]
    var element: JSON { get }
    
//    //in theory, this layout object could access determine child routes dynamically based on the state of the system
//    func generateChildRoutes(state: RSState) -> [RSRoute]
    
    //TODO: how will this work with tab layouts??
    //its quite possible the matched route is not available when the parent tab bar controller is instantiated
    //maybe make a focus view controller method on the RSLayoutViewController that takes the matched route?
    //can we make thsi static??
    func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController
}
