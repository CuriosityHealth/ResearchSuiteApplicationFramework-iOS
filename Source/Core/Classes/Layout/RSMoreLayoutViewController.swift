//
//  RSMoreLayoutViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/15/18.
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

open class RSMoreLayoutViewController: RSLayoutViewController {
    
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
