//
//  RSEnhancedMultipleChoiceValuesResultTransform.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 9/13/17.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
