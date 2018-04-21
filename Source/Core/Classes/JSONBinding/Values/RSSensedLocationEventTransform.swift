//
//  RSSensedLocationEventTransform.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import Gloss
import CoreLocation

open class RSSensedLocationEventTransform: RSValueTransformer {
    public static func supportsType(type: String) -> Bool {
        return type == "sensedLocationEvent"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        guard let sensedLocationEvent = context["sensedLocationEvent"] as? RSLocationEvent else {
            return nil
        }
        return RSValueConvertible(value: sensedLocationEvent)
    }
    
    
}
