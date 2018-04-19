//
//  RSRouteManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
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
import ReSwift

public protocol RSRouteGenerator {
    static func supportsType(type: String) -> Bool
    static func generate(jsonObject: JSON, state: RSState, routeManager: RSRouteManager) -> RSRoute?
}

open class RSRouteManager: NSObject {
    
    public let routeGenerators: [RSRouteGenerator.Type]
    public let pathManager: RSPathManager
    
    public init(
        routeGenerators: [RSRouteGenerator.Type]?,
        pathManager: RSPathManager
        ) {
        self.routeGenerators = routeGenerators ?? []
        self.pathManager = pathManager
        super.init()
    }
    
    open func generateRoute(jsonObject: JSON, state: RSState) -> RSRoute? {
        
        guard let type: String = "type" <~~ jsonObject else {
            return nil
        }
        
        for routeGenerator in self.routeGenerators {
            if routeGenerator.supportsType(type: type),
                let route = routeGenerator.generate(jsonObject: jsonObject, state: state, routeManager: self) {
                return route
            }
        }
        
        return nil
    }

}
