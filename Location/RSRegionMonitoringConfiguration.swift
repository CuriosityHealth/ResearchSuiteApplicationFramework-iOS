//
//  RSRegionMonitoringConfiguration.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//

import UIKit
import Gloss

open class RSRegionMonitoringConfiguration: Gloss.Decodable {
    
    //region monitoring config
    //array of regions
    //each region has an identifier and bound to a location and radius
    //similar to notifications, each region has a predicate, monitored values, and handler actions
    //monitored values cause the region to get "rebuilt" and resubmitted
    //for example, if the radius could potentialy change after it's initially set,
    //we would want to monitor that value for changes. Thus, if it does change, the region will be refreshed
    
    public let regions: [RSRegion]
    
    public required init?(json: JSON) {
        guard let regions: [JSON] = "regions" <~~ json else {
            return nil
        }
        
        self.regions = regions.flatMap { RSRegion(json: $0) }
    }

}
