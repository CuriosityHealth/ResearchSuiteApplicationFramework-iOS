//
//  RSRegion.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//

import UIKit
import Gloss

open class RSRegion: Gloss.Decodable {
    
    //each region has an identifier and bound to a location and radius
    //similar to notifications, each region has a predicate, monitored values, and handler actions
    //monitored values cause the region to get "rebuilt" and resubmitted
    //for example, if the radius could potentialy change after it's initially set,
    //we would want to monitor that value for changes. Thus, if it does change, the region will be refreshed
    
    public let identifier: String
    public let location: JSON
    public let radius: JSON
    public let predicate: RSPredicate?
    public let monitoredValues: [JSON]
    public let onEnterActions: [JSON]?
    public let onExitActions: [JSON]?
    public let initialStateActions: [JSON]?
    public let json: JSON
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let location: JSON = "location" <~~ json,
            let radius: JSON = "radius" <~~ json,
            let monitoredValues: [JSON] = "monitoredValues" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.location = location
        self.radius = radius
        self.predicate = "predicate" <~~ json
        self.monitoredValues = monitoredValues
        self.onExitActions = "onExit" <~~ json
        self.onEnterActions = "onEnter" <~~ json
        self.initialStateActions = "initialState" <~~ json
        self.json = json
        
    }

}
