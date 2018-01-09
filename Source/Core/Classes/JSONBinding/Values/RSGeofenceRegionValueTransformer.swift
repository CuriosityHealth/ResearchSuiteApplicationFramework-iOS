//
//  RSGeofenceRegionValueTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/8/18.
//

import UIKit
import Gloss
import CoreLocation

open class RSGeofenceRegionValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "GeofenceRegion"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        guard let radiusJSON: JSON = "radius" <~~ jsonObject,
            let radius = RSValueManager.processValue(jsonObject: radiusJSON, state: state, context: [:])?.evaluate() as? Double,
            let locationJSON: JSON = "location" <~~ jsonObject,
            let location = RSValueManager.processValue(jsonObject: locationJSON, state: state, context: [:])?.evaluate() as? CLLocation,
            let identifier: String = "identifier" <~~ jsonObject else {
                return nil
        }
        
        let region = CLCircularRegion(center: location.coordinate, radius: radius, identifier: identifier)
        return RSValueConvertible(value: region)
  
    }

}
