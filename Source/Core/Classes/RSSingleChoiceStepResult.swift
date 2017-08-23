//
//  RSSingleChoiceStepResult.swift
//  Pods
//
//  Created by James Kizer on 8/22/17.
//
//

import UIKit
import ResearchKit

open class RSSingleChoiceStepResult: RSDefaultStepResult {

    open override class func type() -> String {
        return "singleChoice"
    }
    
    open override func evaluate() -> AnyObject? {
        guard let choiceQuestionResult = self.result as? ORKChoiceQuestionResult,
                let choice = choiceQuestionResult.choiceAnswers?.first  else {
            return nil
        }
        
        return choice as AnyObject
    }
    
}
