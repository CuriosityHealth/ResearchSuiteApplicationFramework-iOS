//
//  RSRouter.swift
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

public struct RSRedirect {
    let path: String
}

public protocol RSIsEqual {
    func isEqualTo(_ object: Any) -> Bool
}

open class RSRouter {
    
    public struct RSRoutingInstructions {
        let path: String
        let routesStack: [RSMatchedRoute]
    }
    
    public enum RSRouterError: LocalizedError {
        case invalidPath(path: String)
        case redirect(path: String)
        case redirectCycle(path: String)
        
        public var errorDescription: String? {
            switch self {
            case .invalidPath(let path):
                return NSLocalizedString("The path \(path) is invalid.", comment: "Invalid Path")
                
            case .redirect(let path):
                return NSLocalizedString("Redirecting to \(path)", comment: "Redirect")
                
            case .redirectCycle(let path):
                return NSLocalizedString("The path \(path) led to a redirect cycle.", comment: "Redirect Cycle")
            }
            
            
        }
    }
    
    // 1) finds matching routes
    // If path remains,
    // 2) get layout for route
    // 3) generate child routes for layout
    open class func getRouteStackHelper(for path: String, parentMatch: RSMatchedRoute?, routes: [RSRoute], state: RSState, routeManager: RSRouteManager) throws -> [RSMatchedRoute] {
        guard path.hasPrefix("/") else {
            debugPrint("Path not prefixed by '/'")
            let fullPath = parentMatch == nil ? path : (parentMatch!.match.path + path)
            throw RSRouterError.invalidPath(path: fullPath)
        }
        
        //check to see if path is prefixed by any of the route paths
        let matchedRoutes: [RSMatchedRoute] = try routes.compactMap { route in
            let previousPath = parentMatch?.match.path ?? ""
            guard let match = try route.match(remainingPath: path, previousPath: previousPath) else {
                return nil
            }
            
            guard let layout = RSStateSelectors.layout(state, for: route.layoutIdentifier) else {
                throw RSLayoutError.noMatchingLayout(routeIdentifier: route.identifier, layoutIdentifier: route.layoutIdentifier)
            }
            
            return RSMatchedRoute(match: match, route: route, layout: layout)
        }

        assert(matchedRoutes.count <= 1)
        
        // if a route matched
        if let matchedRoute = matchedRoutes.first {
            
            //            debugPrint(matchedRoute)
            //            let layout = matchedRoute.route.layout
            
            let remainingPath = matchedRoute.route.path.remainder(path: path)
            // check to see if there is still path remaining
            //if so, recurse
            if remainingPath.count > 0 {

                //generate child routes
//                let childRoutes: [RSRoute] = layout.generateChildRoutes(state: state)
                //in layout, the child routes are stored as an array of json objects. Map over them generating the route
                //JIT route generation
                //This handles things like protected routes based on state
                let childRoutes: [RSRoute] = matchedRoute.layout.childRoutes(routeManager: routeManager, state: state, matchedRoute: matchedRoute, parentLayout: parentMatch?.layout)
//                let childRoutes: [RSRoute]  = matchedRoute.layout.childRoutes.compactMap { routeManager.generateRoute(jsonObject: $0, state: state) }
                guard childRoutes.count > 0 else {
                    debugPrint("Layout \(matchedRoute.layout.identifier) does not have child routes but the following path is remaining: \(remainingPath)")
                    let fullPath = parentMatch == nil ? path : (parentMatch!.match.path + path)
                    throw RSRouterError.invalidPath(path: fullPath)
                }
                
                let matchedRouteStack = try self.getRouteStackHelper(
                    for: String(remainingPath),
                    parentMatch: matchedRoute,
                    routes: childRoutes,
                    state: state,
                    routeManager: routeManager
                )
                
                return [matchedRoute] + matchedRouteStack
            }
            else {
                return [matchedRoute]
            }
            
        }
        else {
            debugPrint("No route found")
            let fullPath = parentMatch == nil ? path : (parentMatch!.match.path + path)
            throw RSRouterError.invalidPath(path: fullPath)
        }
    }
    
    open class func getRouteStack(for path: String, rootLayoutIdentifier: String, state: RSState, routeManager: RSRouteManager) throws -> [RSMatchedRoute] {
        
        guard let layout = RSStateSelectors.layout(state, for: rootLayoutIdentifier) else {
            throw RSLayoutError.noMatchingLayout(routeIdentifier: "ROOT", layoutIdentifier: rootLayoutIdentifier)
        }
        
//        let childRoutes: [RSRoute]  = layout.childRoutes.compactMap { routeManager.generateRoute(jsonObject: $0, state: state) }
        
        let childRoutes: [RSRoute] = layout.childRoutes(routeManager: routeManager, state: state, matchedRoute: nil, parentLayout: nil)
        
        return try self.getRouteStackHelper(for: path, parentMatch: nil, routes: childRoutes, state: state, routeManager: routeManager)
    }
    
    open class func generateRoutingInstructions(path: String, rootLayoutIdentifier: String, state: RSState, routeManager: RSRouteManager) throws -> RSRoutingInstructions {
        debugPrint("***************************************")
        
        do {
            
            let matchedRouteStack = try self.getRouteStack(for: path, rootLayoutIdentifier: rootLayoutIdentifier, state: state, routeManager: routeManager)
            return RSRoutingInstructions(
                path: path,
                routesStack: matchedRouteStack)
            
        }
        catch RSRouterError.redirect(let redirectPath) {
//            assert(redirectPath != path, "Redirect Cycle")
            if redirectPath == path {
                throw RSRouterError.redirectCycle(path: redirectPath)
            }
            return try self.generateRoutingInstructions(path: redirectPath, rootLayoutIdentifier: rootLayoutIdentifier, state: state, routeManager: routeManager)
        }
        
        debugPrint("***************************************")
        print("\n\n\n")
    }
    
}
