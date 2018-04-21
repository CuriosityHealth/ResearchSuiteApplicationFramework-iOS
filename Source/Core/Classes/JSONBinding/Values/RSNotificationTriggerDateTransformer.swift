//
//  RSNotificationTriggerDateTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/22/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

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

