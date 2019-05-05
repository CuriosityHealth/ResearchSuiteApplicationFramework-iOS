//
//  RSRegionTransitionEvent.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

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
    
    public let regionGroup: RSRegionGroup
    public let region: CLRegion
    public let transition: Transition
    public let timestamp: Date

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

