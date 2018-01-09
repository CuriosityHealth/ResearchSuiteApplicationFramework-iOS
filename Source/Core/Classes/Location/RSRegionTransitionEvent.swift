//
//  RSRegionTransitionEvent.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
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

