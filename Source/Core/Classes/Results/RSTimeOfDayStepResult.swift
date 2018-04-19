//
//  RSTimeOfDayStepResult.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/5/17.
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
