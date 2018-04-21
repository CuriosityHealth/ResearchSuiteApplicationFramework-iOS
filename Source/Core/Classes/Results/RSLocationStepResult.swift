//
//  RSLocationStepResult.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/5/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchKit
import ResearchSuiteResultsProcessor
import Gloss
import CoreLocation

open class RSLocationStepResult: RSDefaultStepResult {
    
    open override class func type() -> String {
        return "location"
    }
    
    @objc open override func evaluate() -> AnyObject? {
        guard let locationResult = self.result as? ORKLocationQuestionResult,
            let coordinate = locationResult.locationAnswer?.coordinate else {
            return nil
        }
        
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
}
