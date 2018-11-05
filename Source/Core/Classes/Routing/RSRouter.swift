//
//  RSRouter.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
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
    
    public enum RSRouterError: LocalizedError {
        case invalidPath(path: String)
        case redirect(path: String)
        case redirectCycle(path: String)
        case pathNotConvertibleToURL(path: String)
        
        public var errorDescription: String? {
            switch self {
            case .invalidPath(let path):
                return NSLocalizedString("The path \(path) is invalid.", comment: "Invalid Path")
                
            case .redirect(let path):
                return NSLocalizedString("Redirecting to \(path)", comment: "Redirect")
                
            case .redirectCycle(let path):
                return NSLocalizedString("The path \(path) led to a redirect cycle.", comment: "Redirect Cycle")
                
            case .pathNotConvertibleToURL(let path):
                return NSLocalizedString("The path \(path) is not convertible to a URL.", comment: "Path Not Convertible To URL")
            }
        }
    }
    
    // 1) finds matching routes
    // If path remains,
    // 2) get layout for route
    // 3) generate child routes for layout
    open class func getRouteStackHelper(for fullURL: URL, uuid: UUID, parentMatch: RSMatchedRoute?, routes: [RSRoute], state: RSState, routeManager: RSRouteManager) throws -> [RSMatchedRoute] {
        
        let previousPath = parentMatch?.match.path ?? ""
        let path = String(fullURL.path.dropFirst(previousPath.count))
        
        guard path.hasPrefix("/") else {
//            debugPrint("Path not prefixed by '/'")
            let fullPath = parentMatch == nil ? path : (parentMatch!.match.path + path)
            throw RSRouterError.invalidPath(path: fullURL.absoluteString)
        }
        
        //check to see if path is prefixed by any of the route paths
        let matchedRoutes: [RSMatchedRoute] = try routes.compactMap { route in
            guard let match = try route.match(remainingPath: path, previousPath: previousPath, fullURL: fullURL) else {
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
//                    debugPrint("Layout \(matchedRoute.layout.identifier) does not have child routes but the following path is remaining: \(remainingPath)")
                    let fullPath = parentMatch == nil ? path : (parentMatch!.match.path + path)
                    throw RSRouterError.invalidPath(path: fullPath)
                }
                
                
//                let newURL = url.
//                let remainingURLString: String = {
//                    if let queryString = url.query {
//                        return "\(remainingPath)?\(queryString)"
//                    }
//                    else {
//                        return remainingPath
//                    }
//                }()
//                
//                guard let remainingURL = URL(string: remainingURLString) else {
//                    throw RSRouterError.pathNotConvertibleToURL(path: remainingURLString)
//                }
                
                let matchedRouteStack = try self.getRouteStackHelper(
                    for: fullURL,
                    uuid: uuid,
                    parentMatch: matchedRoute,
                    routes: childRoutes,
                    state: state,
                    routeManager: routeManager
                )
                
                return [matchedRoute] + matchedRouteStack
            }
            else {
                
                //need to do somthing with query string here...
                return [matchedRoute]
            }
            
        }
        else {
//            debugPrint("No route found")
            let fullPath = parentMatch == nil ? path : (parentMatch!.match.path + path)
            throw RSRouterError.invalidPath(path: fullPath)
        }
    }
    
    open class func getRouteStack(for url: URL, uuid: UUID, rootLayoutIdentifier: String, state: RSState, routeManager: RSRouteManager) throws -> [RSMatchedRoute] {
        
        guard let layout = RSStateSelectors.layout(state, for: rootLayoutIdentifier) else {
            throw RSLayoutError.noMatchingLayout(routeIdentifier: "ROOT", layoutIdentifier: rootLayoutIdentifier)
        }
        
//        let childRoutes: [RSRoute]  = layout.childRoutes.compactMap { routeManager.generateRoute(jsonObject: $0, state: state) }
        
        let childRoutes: [RSRoute] = layout.childRoutes(routeManager: routeManager, state: state, matchedRoute: nil, parentLayout: nil)
        
        return try self.getRouteStackHelper(for: url, uuid: uuid, parentMatch: nil, routes: childRoutes, state: state, routeManager: routeManager)
    }
    
    open class func generateRoutingInstructions(path: String, uuid: UUID, rootLayoutIdentifier: String, state: RSState, routeManager: RSRouteManager) throws -> RSRoutingInstructions {
        
        
        guard let url = URL(string: path) else {
            throw RSRouterError.pathNotConvertibleToURL(path: path)
        }
        
        do {
            
            let matchedRouteStack = try self.getRouteStack(for: url, uuid: uuid, rootLayoutIdentifier: rootLayoutIdentifier, state: state, routeManager: routeManager)
            return RSRoutingInstructions(
                path: path,
                routesStack: matchedRouteStack)
            
        }
        catch RSRouterError.redirect(let redirectPath) {
//            assert(redirectPath != path, "Redirect Cycle")
            if redirectPath == path {
                throw RSRouterError.redirectCycle(path: redirectPath)
            }
            return try self.generateRoutingInstructions(path: redirectPath, uuid: uuid, rootLayoutIdentifier: rootLayoutIdentifier, state: state, routeManager: routeManager)
        }
    }
    
    open class func canRoute(path: String, rootLayoutIdentifier: String, state: RSState, routeManager: RSRouteManager) -> Bool {
        
        
        do {
            let _ = try RSRouter.generateRoutingInstructions(
                path: path,
                uuid: UUID(),
                rootLayoutIdentifier: rootLayoutIdentifier,
                state: state,
                routeManager: routeManager
            )
            
            return true
        }
        catch _ {
            return false
        }
        
    }
    
}
