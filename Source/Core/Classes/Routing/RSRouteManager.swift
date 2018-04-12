//
//  RSRouteManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//

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
