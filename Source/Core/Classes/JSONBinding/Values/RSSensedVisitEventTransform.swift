//
//  RSSensedVisitEventTransform.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/10/18.
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
