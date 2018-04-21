//
//  RSSensedRegionTransitionEventTransform.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

//import UIKit
import Gloss
import CoreLocation

open class RSSensedRegionTransitionEventTransform: RSValueTransformer {
    public static func supportsType(type: String) -> Bool {
        return type == "sensedRegionTransitionEvent"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        guard let sensedRegionTransitionEvent = context["sensedRegionTransitionEvent"] as? RSRegionTransitionEvent else {
            return nil
        }
        return RSValueConvertible(value: sensedRegionTransitionEvent)
    }
    
    
}
