//
//  RSLayout.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

public enum RSLayoutError: Error {
    case cannotInstantiateLayout(layoutIdentifier: String)
    case noMatchingLayout(routeIdentifier: String, layoutIdentifier: String)
}

public struct RSOnNewState: JSONDecodable {
    public let actions: [JSON]
    public let monitoredValues: [JSON]
    
    public init?(json: JSON) {
        self.actions = "actions" <~~ json ?? []
        self.monitoredValues = "monitoredValues" <~~ json ?? []
    }
    
    public init() {
        self.actions = []
        self.monitoredValues = []
    }
}

//A Layout is more or less a template for a view controller
public protocol RSLayout: RSIsEqual {
    var identifier: String { get }
    var type: String { get }
    //when loaded into memory - analogous to viewDidLoad
    var onLoadActions: [JSON] { get }
    //when the layout is on the tap of the stack for the FIRST time in its lifecycle
    var onFirstAppearanceActions: [JSON] { get }
    var onNewStateActions: RSOnNewState { get }
    var hidesNavBar: Bool { get }
    
    var navTitle: String? { get }
    //deprecated
    var navButtonRight: RSLayoutButton? { get }
    var rightNavButtons: [RSLayoutButton]? { get }
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
