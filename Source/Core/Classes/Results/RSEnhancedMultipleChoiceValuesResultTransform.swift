//
//  RSEnhancedMultipleChoiceValuesResultTransform.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 9/13/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchSuiteExtensions

//this class extracts all the values assocated with the enhancedMultipleChoice result
//this helps with predicates
class RSEnhancedMultipleChoiceValuesResultTransform: RSDefaultStepResult {
    open override class func type() -> String {
        return "enhancedMultipleChoiceValues"
    }
    
    @objc open override func evaluate() -> AnyObject? {

        guard let result = self.result as? RSEnhancedMultipleChoiceResult,
            let choiceAnswers = result.choiceAnswers else {
            return [NSString]() as AnyObject
        }
        
        let choices: [NSString] = choiceAnswers.compactMap { (selection) -> NSString? in
            return selection.value as? NSString
        }
        
        return choices as AnyObject
    }
}
