//
//  RSNotificationTriggerDateTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/22/17.
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

import UIKit
import Gloss

///this should be able to take a list of things that evaluate to date components and merge them
open class RSNotificationTriggerDateTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "notificationTriggerDate"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        guard let notificationID: String = "identifier" <~~ jsonObject,
            let notification = RSStateSelectors.notification(state, for: notificationID),
            let notificationManager = RSApplicationDelegate.appDelegate.notificationManager,
            let nextTriggerDate = notificationManager.nextTriggerDate(notification: notification, state: state) else {
                return nil
        }
        
        return RSValueConvertible(value: nextTriggerDate as NSDate)
    }
    
    
}

