//
//  RSRegionGroup.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSRegionGroup: Gloss.JSONDecodable {
    
    //each region has an identifier and bound to a location and radius
    //similar to notifications, each region has a predicate, monitored values, and handler actions
    //monitored values cause the region to get "rebuilt" and resubmitted
    //for example, if the radius could potentialy change after it's initially set,
    //we would want to monitor that value for changes. Thus, if it does change, the region will be refreshed
    
    public let identifier: String
    public let region: JSON?
    public let regions: JSON?
    public let predicate: RSPredicate?
    public let onEnterActions: [JSON]?
    public let onExitActions: [JSON]?
    public let onStateActions: [JSON]?
    public let json: JSON
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.region = "region" <~~ json
        self.regions = "regions" <~~ json
        self.predicate = "predicate" <~~ json
        self.onExitActions = "onExit" <~~ json
        self.onEnterActions = "onEnter" <~~ json
        self.onStateActions = "onState" <~~ json
        self.json = json
        
    }

}
