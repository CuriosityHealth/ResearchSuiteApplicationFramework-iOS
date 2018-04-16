//
//  RSPrintNotificationActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//

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
