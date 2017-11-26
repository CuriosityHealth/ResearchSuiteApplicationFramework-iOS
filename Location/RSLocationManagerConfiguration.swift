//
//  RSLocationManagerConfiguration.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/25/17.
//

import UIKit
import Gloss

open class RSLocationManagerConfiguration: Gloss.Decodable {
    
    //location config
    //by default, we do not monitor location changes
    //TODO: Add support for significant location changes
    //TODO: Add support for regular location changes
    //We do provide an action to request the current location
    //The config should provide a list of actions to execute when a new location is processed
    //RSSensedLocationValueTransform should support this
    public let locationConfig: RSLocationConfiguration?
    
    //region monitoring config
    //array of regions
    //each region has an identifier and bound to a location and radius
    //similar to notifications, each region has a predicate, monitored values, and handler actions
    //monitored values cause the region to get "rebuilt" and resubmitted
    //for example, if the radius could potentialy change after it's initially set,
    //we would want to monitor that value for changes. Thus, if it does change, the region will be refreshed
//    public let regionMonitoringConfig: RSRegionMonitoringConfiguration?
    
    required public init?(json: JSON) {
        
        self.locationConfig = "location" <~~ json
        
    }

}
