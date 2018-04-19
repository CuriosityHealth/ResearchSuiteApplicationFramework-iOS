//
//  RSRoute.swift
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

open class RSRoute: CustomStringConvertible, Equatable, RSRouteGenerator {
    open class func supportsType(type: String) -> Bool {
        return type == "route"
    }
    
    open class func generate(jsonObject: JSON, state: RSState, routeManager: RSRouteManager) -> RSRoute? {
        
        //first generate path
        guard let identifier: String = "identifier" <~~ jsonObject,
            let layoutIdentifier: String = "layout" <~~ jsonObject,
            let pathJSON: JSON = "path" <~~ jsonObject,
            let path = routeManager.pathManager.generatePath(jsonObject: pathJSON, state: state) else {
                return nil
        }
        
        return RSRoute(identifier: identifier, path: path, layoutIdentifier: layoutIdentifier)
    }
    
    public static func == (lhs: RSRoute, rhs: RSRoute) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public var description: String {
        return "Route: Path - \(self.path): Layout: \(self.layoutIdentifier)"
    }
    
    public let path: RSPath
    public let layoutIdentifier: String
    public let identifier: String
    
    public init(identifier: String, path: RSPath, layoutIdentifier: String) {
        self.identifier = identifier
        self.path = path
        self.layoutIdentifier = layoutIdentifier
    }
    
    open func match(remainingPath: String, previousPath: String) throws -> RSMatch? {
        return self.path.match(remainingPath: remainingPath, previousPath: previousPath)
    }
    
}

open class RSRedirectRoute: RSRoute {
    
    let redirectPath: String
    public init(identifier: String, path: RSPath, redirectPath: String) {
        self.redirectPath = redirectPath
        super.init(identifier: identifier, path: path, layoutIdentifier: "redirect")
    }
    
    override open func match(remainingPath: String, previousPath: String) throws -> RSMatch? {
        
        if let _ = self.path.match(remainingPath: remainingPath, previousPath: previousPath) {
            throw RSRouter.RSRouterError.redirect(path: self.redirectPath)
        }
        else {
            return nil
        }
        
    }
    
    open override class func supportsType(type: String) -> Bool {
        return type == "redirect"
    }
    
    open override class func generate(jsonObject: JSON, state: RSState, routeManager: RSRouteManager) -> RSRoute? {
        
        //first generate path
        guard let identifier: String = "identifier" <~~ jsonObject,
            let redirectPath: String = "redirectPath" <~~ jsonObject,
            let pathJSON: JSON = "path" <~~ jsonObject,
            let path = routeManager.pathManager.generatePath(jsonObject: pathJSON, state: state) else {
                return nil
        }
        
        return RSRedirectRoute(identifier: identifier, path: path, redirectPath: redirectPath)
    }
    
}
