//
//  RSMoreLayoutViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/15/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit

open class RSMoreLayoutViewController: RSLayoutViewController {
    
    public func reloadLayout() {
        
    }
    
    public let uuid: UUID = UUID()
    
    public init(identifier: String, matchedRoute: RSMatchedRoute, parent: RSLayoutViewController) {
        self.matchedRoute = matchedRoute
        self.parentLayoutViewController = parent
        let tabBarController = parent.viewController as! UITabBarController
//        self.viewController = tabBarController
        self.identifier = identifier
        
    }

    public var identifier: String!
    
    public var matchedRoute: RSMatchedRoute!
    
    public var layout: RSLayout! {
        return matchedRoute.layout
    }
    
    public var viewController: UIViewController!
    
    public var parentLayoutViewController: RSLayoutViewController!
    
    public func layoutDidLoad() {
        
    }
    
    public func layoutDidAppear(initialAppearance: Bool) {
        
    }
    
    public func backTapped() {
        
    }
    
    public func updateLayout(matchedRoute: RSMatchedRoute, state: RSState) {

    }
    
    public func present(matchedRoutes: [RSMatchedRoute], animated: Bool, state: RSState, completion: ((RSLayoutViewController?, Error?) -> Void)?) {
        
        //we need to do this in the parent tab bar
        if matchedRoutes.count > 0 {
            self.parentLayoutViewController.present(matchedRoutes: matchedRoutes, animated: animated, state: state, completion: completion)
        }
        else {
            completion?(self, nil)
        }
        
        
    }
    

}
