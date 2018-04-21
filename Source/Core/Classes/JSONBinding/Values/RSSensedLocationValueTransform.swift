//
//  RSSensedLocationValueTransform.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import CoreLocation

open class RSSensedLocationValueTransform: RSValueTransformer {
    public static func supportsType(type: String) -> Bool {
        return type == "sensedLocation"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        guard let sensedLocation = context["sensedLocation"] as? CLLocation else {
            return nil
        }
        return RSValueConvertible(value: sensedLocation)
    }
    

}
