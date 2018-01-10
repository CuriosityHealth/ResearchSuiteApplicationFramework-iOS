//
//  RSSensedVisitEventTransform.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/10/18.
//

import Gloss
import CoreLocation

open class RSSensedVisitEventTransform: RSValueTransformer {
    public static func supportsType(type: String) -> Bool {
        return type == "sensedVisitEvent"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        guard let sensedVisitEvent = context["sensedVisitEvent"] as? RSVisitEvent else {
            return nil
        }
        return RSValueConvertible(value: sensedVisitEvent)
    }
    
    
}
