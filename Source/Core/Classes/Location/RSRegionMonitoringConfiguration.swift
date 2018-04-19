//
//  RSRegionMonitoringConfiguration.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
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

open class RSRegionMonitoringConfiguration: Gloss.JSONDecodable {
    
    //region monitoring config
    //array of regions
    //each region has an identifier and bound to a location and radius
    //similar to notifications, each region has a predicate, monitored values, and handler actions
    //monitored values cause the region to get "rebuilt" and resubmitted
    //for example, if the radius could potentialy change after it's initially set,
    //we would want to monitor that value for changes. Thus, if it does change, the region will be refreshed
    
    public let regionGroups: [RSRegionGroup]
    
    public required init?(json: JSON) {
        guard let groups: [JSON] = "region_groups" <~~ json else {
            return nil
        }
        
        self.regionGroups = groups.compactMap { RSRegionGroup(json: $0) }
    }

}
