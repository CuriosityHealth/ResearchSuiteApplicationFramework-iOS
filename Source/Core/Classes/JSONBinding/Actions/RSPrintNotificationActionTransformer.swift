//
//  RSPrintNotificationActionTransformer.swift
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
import ReSwift
import UserNotifications

open class RSPrintNotificationActionTransformer: RSActionTransformer {
    
    open static func supportsType(type: String) -> Bool {
        return "printNotification" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let identifier: String = "identifier" <~~ jsonObject else {
            return nil
        }
        
        return { state, store in
            
            guard let pendingNotifications = RSStateSelectors.pendingNotifications(state),
                let pendingNotification = pendingNotifications.first(where: { $0.identifier == identifier }) else {
                return nil
            }
            
            debugPrint(pendingNotification)
            if let trigger = pendingNotification.trigger as? UNTimeIntervalNotificationTrigger,
                let date = trigger.nextTriggerDate() {
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.timeZone = TimeZone.current
                debugPrint(dateFormatter.string(from: date))
            }
            else if let trigger = pendingNotification.trigger as? UNCalendarNotificationTrigger,
                let date = trigger.nextTriggerDate() {
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.timeZone = TimeZone.current
                debugPrint(dateFormatter.string(from: date))
            }
            
            
            return nil
            
        }
    }
    
}
