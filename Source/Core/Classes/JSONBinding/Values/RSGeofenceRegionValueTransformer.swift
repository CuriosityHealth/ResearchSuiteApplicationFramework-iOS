//
//  RSGeofenceRegionValueTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/8/18.
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
