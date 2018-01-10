//
//  RSLocationEvent.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//

import UIKit
import CoreLocation
import ResearchSuiteResultsProcessor

open class RSLocationEvent: RSRPIntermediateResult {
    
    public static let kType = "RSLocationEvent"
    
    open let location: CLLocation
    init(location: CLLocation, source: String, uuid: UUID) {
        self.location = location
        super.init(
            type: RSLocationEvent.kType,
            uuid: uuid,
            taskIdentifier: source,
            taskRunUUID: UUID()
        )
    }

}
