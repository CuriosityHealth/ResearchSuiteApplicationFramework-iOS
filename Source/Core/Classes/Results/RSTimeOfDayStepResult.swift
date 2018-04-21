//
//  RSTimeOfDayStepResult.swift
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

open class RSTimeOfDayStepResult: RSDefaultStepResult {
    
    open override class func type() -> String {
        return "timeOfDay"
    }
    
    open override func evaluate() -> AnyObject? {
        guard let timeOfDayResult = self.result as? ORKTimeOfDayQuestionResult,
            let dateComponents = timeOfDayResult.dateComponentsAnswer else {
                return nil
        }
        
        return dateComponents as AnyObject
    }
    
}
