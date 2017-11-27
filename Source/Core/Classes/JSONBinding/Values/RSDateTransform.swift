//
//  RSDateTransform.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//

import UIKit

import UIKit
import Gloss

///this should be able to take a list of things that evaluate to date components and merge them
open class RSDateTransform: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "date"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        //we have a list of values that should evaluate to either date or date components
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
        
        return RSValueConvertible(value: date.addingTimeInterval(timeInterval) as NSDate)
    }
    
    
}
