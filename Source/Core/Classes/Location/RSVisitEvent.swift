//
//  RSVisitEvent.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import CoreLocation
import ResearchSuiteResultsProcessor

open class RSVisitEvent: RSRPIntermediateResult {
    
    public static let kType = "RSVisitEvent"
    
    open let visit: CLVisit
    open let timestamp: Date
    init(visit: CLVisit, source: String, uuid: UUID, timestamp: Date = Date()) {
        self.visit = visit
        self.timestamp = timestamp
        super.init(
            type: RSLocationEvent.kType,
            uuid: uuid,
            taskIdentifier: source,
            taskRunUUID: UUID()
        )
    }
    
}
