//
//  RSBooleanStepResult.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/6/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchKit

open class RSBooleanStepResult: RSDefaultStepResult {
    
    open override class func type() -> String {
        return "boolean"
    }
    
    @objc open override func evaluate() -> AnyObject? {
        guard let booleanQuestionResult = self.result as? ORKBooleanQuestionResult else {
                return nil
        }
        
        return booleanQuestionResult.booleanAnswer
    }
    
}
