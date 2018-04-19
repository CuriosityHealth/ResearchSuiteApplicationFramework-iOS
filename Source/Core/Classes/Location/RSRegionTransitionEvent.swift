//
//  RSRegionTransitionEvent.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
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
import CoreLocation
import ResearchSuiteResultsProcessor

open class RSRegionTransitionEvent: RSRPIntermediateResult {
    
    public static let kType = "RSRegionTransitionEvent"
    
    public enum Transition: String {
        case enter = "enter"
        case exit = "exit"
        case startedInside = "startedInside"
        case startedOutside = "startedOutside"
        case startedUnknown = "startedUnknown"
    }
    
    open let regionGroup: RSRegionGroup
    open let region: CLRegion
    open let transition: Transition
    open let timestamp: Date

    init(regionGroup: RSRegionGroup, region: CLRegion, transition: Transition, source: String, uuid: UUID, timestamp: Date) {
        self.regionGroup = regionGroup
        self.region = region
        self.transition = transition
        self.timestamp = timestamp
        super.init(
            type: RSRegionTransitionEvent.kType,
            uuid: uuid,
            taskIdentifier: source,
            taskRunUUID: UUID()
        )
    }
    
}

