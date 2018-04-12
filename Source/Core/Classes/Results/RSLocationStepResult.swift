//
//  RSLocationStepResult.swift
//  Pods
//
//  Created by James Kizer on 7/5/17.
//
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
