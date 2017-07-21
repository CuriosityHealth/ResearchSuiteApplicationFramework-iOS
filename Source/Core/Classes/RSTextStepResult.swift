//
//  RSTextStepResult.swift
//  Pods
//
//  Created by James Kizer on 7/21/17.
//
//

import UIKit
import ResearchKit

class RSTextStepResult: RSDefaultStepResult {

    open override class func type() -> String {
        return "text"
    }
    
    open override func evaluate() -> AnyObject? {
        
        if result == nil {
            return NSNull()
        }
        
        guard let result = self.result as? ORKTextQuestionResult else {
                return nil
        }
        
        return result.textAnswer as AnyObject?
    }
    
}
