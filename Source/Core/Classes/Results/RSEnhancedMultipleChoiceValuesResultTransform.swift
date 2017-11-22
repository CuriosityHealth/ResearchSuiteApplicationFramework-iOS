//
//  RSEnhancedMultipleChoiceValuesResultTransform.swift
//  Pods
//
//  Created by James Kizer on 9/13/17.
//
//

import UIKit
import ResearchSuiteExtensions

//this class extracts all the values assocated with the enhancedMultipleChoice result
//this helps with predicates
class RSEnhancedMultipleChoiceValuesResultTransform: RSDefaultStepResult {
    open override class func type() -> String {
        return "enhancedMultipleChoiceValues"
    }
    
    open override func evaluate() -> AnyObject? {

        guard let result = self.result as? RSEnhancedMultipleChoiceResult,
            let choiceAnswers = result.choiceAnswers else {
            return [NSString]() as AnyObject
        }
        
        let choices: [NSString] = choiceAnswers.flatMap { (selection) -> NSString? in
            return selection.value as? NSString
        }
        
        return choices as AnyObject
    }
}
