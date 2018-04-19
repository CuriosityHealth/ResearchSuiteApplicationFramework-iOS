//
//  RSProtectedRoute.swift
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

open class RSProtectedRoute: RSRouteGenerator {
    
    open class func supportsType(type: String) -> Bool {
        return type == "protected"
    }
    
    open class func generate(jsonObject: JSON, state: RSState, routeManager: RSRouteManager) -> RSRoute? {
        
        //get predicate
        guard let identifier: String = "identifier" <~~ jsonObject,
            let predicate: RSPredicate = "predicate" <~~ jsonObject,
            let pathJSON: JSON = "path" <~~ jsonObject,
            let path = routeManager.pathManager.generatePath(jsonObject: pathJSON, state: state) else {
            return nil
        }
        
        if RSPredicateManager.evaluatePredicate(predicate: predicate, state: state, context: [:]) {
            
            guard let layoutIdentifier: String = "layout" <~~ jsonObject else {
                return nil
            }
            
            return RSRoute(identifier: identifier, path: path, layoutIdentifier: layoutIdentifier)
        }
        else {
            guard let redirectPath: String = "redirectPath" <~~ jsonObject else {
                return nil
            }
            
            return RSRedirectRoute(identifier: identifier, path: path, redirectPath: redirectPath)
        }
        
    }
    
//    let redirectRoute: RSRedirectRoute
//    let predicate: () -> Bool
//    public init(identifier: String, path: RSPath, layoutIdentifier: String, redirectPath: String, predicate: @escaping ()-> Bool) {
//        self.predicate = predicate
//        self.redirectRoute = RSRedirectRoute(identifier: identifier, path: path, redirectPath: redirectPath)
//        super.init(identifier: identifier, path: path, layoutIdentifier: layoutIdentifier)
//    }
//
//    open override func match(remainingPath: String, previousPath: String) throws -> RSMatch? {
//
//        if self.predicate() {
//            return try super.match(remainingPath: remainingPath, previousPath: previousPath)
//        }
//        else {
//            return try self.redirectRoute.match(remainingPath: remainingPath, previousPath: previousPath)
//        }
//
//    }
    
}
