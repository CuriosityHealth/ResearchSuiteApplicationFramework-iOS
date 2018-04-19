//
//  RSDateTransform.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
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
import Gloss

///this should be able to take a list of things that evaluate to date components and merge them
open class RSDateTransform: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "date"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        //we have a list of values that should evaluate to either date or date components
        let subtracting: Bool = "subtract" <~~ jsonObject ?? false
        
        let date: Date = {
            guard let afterDateJSON: JSON = "date" <~~ jsonObject,
                let afterDate = RSValueManager.processValue(jsonObject: afterDateJSON, state: state, context: [:])?.evaluate() as? NSDate else {
                    return nil
            }
            
            return afterDate as Date
        }() ?? Date()
        
        let timeInterval: TimeInterval = {
            guard let timeIntervalJSON: JSON = "timeInterval" <~~ jsonObject else {
                return nil
            }
            
            return RSValueManager.processValue(jsonObject: timeIntervalJSON, state: state, context: [:])?.evaluate() as? TimeInterval
        }() ?? 0.0
        
        if subtracting {
            return RSValueConvertible(value: date.addingTimeInterval(-timeInterval) as NSDate)
        }
        else {
            return RSValueConvertible(value: date.addingTimeInterval(timeInterval) as NSDate)
        }
        
        
    }
    
    
}
