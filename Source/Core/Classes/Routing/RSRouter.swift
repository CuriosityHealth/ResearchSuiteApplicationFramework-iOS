//
//  RSRouter.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
//

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
    
    public enum RSRouterError: Error {
        case invalidPath
        case redirect(path: String)
        case redirectCycle
    }
    
    // 1) finds matching routes
    // If path remains,
    // 2) get layout for route
    // 3) generate child routes for layout
    open class func getRouteStackHelper(for path: String, previousPath: String, routes: [RSRoute], state: RSState, routeManager: RSRouteManager) throws -> [RSMatchedRoute] {
        guard path.hasPrefix("/") else {
            debugPrint("Path not prefixed by '/'")
            throw RSRouterError.invalidPath
        }
        
        //check to see if path is prefixed by any of the route paths
        let matchedRoutes: [RSMatchedRoute] = try routes.compactMap { route in
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
                let childRoutes: [RSRoute] = matchedRoute.layout.childRoutes(routeManager: routeManager, state: state)
//                let childRoutes: [RSRoute]  = matchedRoute.layout.childRoutes.compactMap { routeManager.generateRoute(jsonObject: $0, state: state) }
                guard childRoutes.count > 0 else {
                    debugPrint("Layout \(matchedRoute.layout.identifier) does not have child routes but the following path is remaining: \(remainingPath)")
                    throw RSRouterError.invalidPath
                }
                
                let matchedRouteStack = try self.getRouteStackHelper(
                    for: String(remainingPath),
                    previousPath: matchedRoute.match.path,
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
            throw RSRouterError.invalidPath
        }
    }
    
    open class func getRouteStack(for path: String, rootLayoutIdentifier: String, state: RSState, routeManager: RSRouteManager) throws -> [RSMatchedRoute] {
        
        guard let layout = RSStateSelectors.layout(state, for: rootLayoutIdentifier) else {
            throw RSLayoutError.noMatchingLayout(routeIdentifier: "ROOT", layoutIdentifier: rootLayoutIdentifier)
        }
        
//        let childRoutes: [RSRoute]  = layout.childRoutes.compactMap { routeManager.generateRoute(jsonObject: $0, state: state) }
        
        let childRoutes: [RSRoute] = layout.childRoutes(routeManager: routeManager, state: state)
        
        return try self.getRouteStackHelper(for: path, previousPath: "", routes: childRoutes, state: state, routeManager: routeManager)
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
            assert(redirectPath != path, "Redirect Cycle")
            if redirectPath == path {
                throw RSRouterError.redirectCycle
            }
            return try self.generateRoutingInstructions(path: redirectPath, rootLayoutIdentifier: rootLayoutIdentifier, state: state, routeManager: routeManager)
        }
        
        debugPrint("***************************************")
        print("\n\n\n")
    }
    
}
