//
//  RSLayout.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
//

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
    var onLoadActions: [JSON] { get }
    var navTitle: String? { get }
    var navButtonRight: RSLayoutButton? { get }
    var onBackActions: [JSON] { get }
    var childRoutes: [JSON] { get }
    var element: JSON { get }
    
//    //in theory, this layout object could access determine child routes dynamically based on the state of the system
//    func generateChildRoutes(state: RSState) -> [RSRoute]
    
    //TODO: how will this work with tab layouts??
    //its quite possible the matched route is not available when the parent tab bar controller is instantiated
    //maybe make a focus view controller method on the RSLayoutViewController that takes the matched route?
    //can we make thsi static??
    func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController
}
