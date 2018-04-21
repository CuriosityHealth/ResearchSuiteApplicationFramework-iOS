//
//  RSScaleStepResult.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 9/13/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchKit

class RSScaleStepResult: RSDefaultStepResult {
    open override class func type() -> String {
        return "scale"
    }
    
    @objc open override func evaluate() -> AnyObject? {
        guard let scaleQuestionResult = self.result as? ORKScaleQuestionResult else {
            return nil
        }
        
        return scaleQuestionResult.scaleAnswer
    }
}
