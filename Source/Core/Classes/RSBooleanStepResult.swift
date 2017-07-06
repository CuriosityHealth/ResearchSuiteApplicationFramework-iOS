//
//  RSBooleanStepResult.swift
//  Pods
//
//  Created by James Kizer on 7/6/17.
//
//

import UIKit
import ResearchKit

open class RSBooleanStepResult: RSDefaultStepResult {
    
    open override class func type() -> String {
        return "boolean"
    }
    
    open override func evaluate() -> AnyObject? {
        guard let booleanQuestionResult = self.result as? ORKBooleanQuestionResult else {
                return nil
        }
        
        return booleanQuestionResult.booleanAnswer
    }
    
}
