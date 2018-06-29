//
//  RSStandardNotificationProcessor.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import UserNotifications

open class RSStandardNotificationProcessor: NSObject, RSNotificationProcessor {
    
    
    public func supportsType(type: String) -> Bool {
        return type == "standard"
    }

    public func shouldUpdate(notification: RSNotification, state: RSState, lastState: RSState) -> Bool {
        guard let standardNotification = RSStandardNotification(json: notification.json),
            let pendingNotificationIdentifiers = RSStateSelectors.pendingNotificationIdentifiers(state) else {
            return false
        }
        
        //first, check to see if notification id is in list of pending notifications
        //if not, need to update, so return true
        if !pendingNotificationIdentifiers.contains(notification.identifier) {
            return true
        }
        
        //otherwise, check monitored values to see if they changed between state and last state
        let detectedDifferences: Bool = standardNotification.monitoredValues.reduce(false) { (acc, monitoredValue) -> Bool in
            return acc || RSValueManager.valueChanged(jsonObject: monitoredValue, state: state, lastState: lastState, context: [:])
        }
        
        if detectedDifferences {
            return true
        }
        else {
            return false
        }
        
    }
    
    private func generateInitialFireInterval(afterDate: Date?, timeInterval: TimeInterval?, dateComopnents: DateComponents?) -> TimeInterval? {
        
        let startDate:Date = afterDate ?? Date()
        let computedTimeInterval: TimeInterval = timeInterval ?? 0.0
        assert(computedTimeInterval >= 0)
        
        if let components = dateComopnents {
            let calendar = Calendar(identifier: .gregorian)
            //I'm not sure this is doing what we want it to do
            //for example, say i'd like to deliver a notification 1 week after baseline, but want to round to
            let after = startDate.addingTimeInterval(computedTimeInterval)
            if let fireDate = calendar.nextDate(after: after, matching: components, matchingPolicy: .strict) {
                return fireDate.timeIntervalSinceNow
            }
            else {
                return nil
            }
        }
        else {
            assert(afterDate != nil || timeInterval != nil)
            return startDate.addingTimeInterval(computedTimeInterval).timeIntervalSinceNow
        }
    }
    
    //compute initial fire interval
    //if interval is not in the json, move on to repeating
    //if interval is less than 0, meaning that it is in the past, move on to repeating
    //otherwise, create time interval trigger
    
    //NOTE: Check this logic, #BallmerTime
    public func generateNotificationRequest(notification: RSNotification, state: RSState, lastState: RSState) -> UNNotificationRequest? {
        guard let descriptor = RSStandardNotification(json: notification.json) else {
            return nil
        }
        
        if let initialFire = descriptor.initialFire {
            
            let date: Date? = {
                guard let afterDateJSON: JSON = "afterDate" <~~ initialFire,
                    let afterDate = RSValueManager.processValue(jsonObject: afterDateJSON, state: state, context: [:])?.evaluate() as? NSDate else {
                    return nil
                }
                
                return afterDate as Date
            }()
            
            let timeInterval: TimeInterval? = {
                guard let timeIntervalJSON: JSON = "timeInterval" <~~ initialFire else {
                        return nil
                }
                
                return RSValueManager.processValue(jsonObject: timeIntervalJSON, state: state, context: [:])?.evaluate() as? TimeInterval
            }()
            
            let dateComponents: DateComponents? = {
                guard let dateComponentsJSON: JSON = "dateComponents" <~~ initialFire,
                    let dateComponents = RSValueManager.processValue(jsonObject: dateComponentsJSON, state: state, context: [:])?.evaluate() as? NSDateComponents else {
                        return nil
                }
                
                return dateComponents as DateComponents
            }()
            
            guard let delayInterval = self.generateInitialFireInterval(afterDate: date, timeInterval: timeInterval, dateComopnents: dateComponents) else {
                return nil
            }
            
            if delayInterval > 0 {
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delayInterval, repeats: false)
                
                // Enable or disable features based on authorization
                let content = UNMutableNotificationContent()
                content.title = descriptor.title
                content.body = descriptor.body
                content.sound = UNNotificationSound.default()
                
                let request = UNNotificationRequest(
                    identifier: descriptor.identifier,
                    content: content,
                    trigger: trigger
                )
                
                return request
                
            }
            //else, fall through to repeating interval
            
        }
        
        if let repeating = descriptor.repeating {
            if let repeatInterval: TimeInterval = {
                guard let timeIntervalJSON: JSON = "timeInterval" <~~ repeating else {
                    return nil
                }
                
                return RSValueManager.processValue(jsonObject: timeIntervalJSON, state: state, context: [:])?.evaluate() as? TimeInterval
                }() {
                
                //this actually sets repeating interval from now, but we actually want it anchored at the last
                //assume this is ok for now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: repeatInterval, repeats: true)
                
                // Enable or disable features based on authorization
                let content = UNMutableNotificationContent()
                content.title = RSApplicationDelegate.localizedString(descriptor.title)
                content.body = RSApplicationDelegate.localizedString(descriptor.body)
                content.sound = UNNotificationSound.default()
                
                let request = UNNotificationRequest(
                    identifier: descriptor.identifier,
                    content: content,
                    trigger: trigger
                )
                
                return request
                
            }
            
            else if let repeatComponents: DateComponents = {
                guard let dateComponentsJSON: JSON = "dateComponents" <~~ repeating,
                    let dateComponents = RSValueManager.processValue(jsonObject: dateComponentsJSON, state: state, context: [:])?.evaluate() as? NSDateComponents else {
                        return nil
                }
                
                return dateComponents as DateComponents
                }() {
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: repeatComponents, repeats: true)
                
                // Enable or disable features based on authorization
                let content = UNMutableNotificationContent()
                content.title = RSApplicationDelegate.localizedString(descriptor.title)
                content.body = RSApplicationDelegate.localizedString(descriptor.body)
                content.sound = UNNotificationSound.default()
                
                let request = UNNotificationRequest(
                    identifier: descriptor.identifier,
                    content: content,
                    trigger: trigger
                )
                
                return request
                
            }
            
        }
        
        return nil
    }
    
    public func shouldCancelFilter(notification: RSNotification, state: RSState) -> (String) -> Bool {
        return { _ in false }
    }
    
    public func identifierFilter(notification: RSNotification) -> (String) -> Bool {
        return { $0 == notification.identifier }
    }
    
    public func nextTriggerDate(notification: RSNotification, state: RSState) -> Date? {
        
        guard let notificationRequests = RSStateSelectors.pendingNotifications(state) else {
            return nil
        }
        
        let filter = identifierFilter(notification: notification)
        let filteredNotificationRequests:[UNNotificationRequest] = notificationRequests.filter( { filter($0.identifier) } )
        let filteredDates: [Date] = filteredNotificationRequests.compactMap { (notificationRequest) -> Date? in
            if let trigger = notificationRequest.trigger as? UNTimeIntervalNotificationTrigger {
                return trigger.nextTriggerDate()
            }
            else if let trigger = notificationRequest.trigger as? UNCalendarNotificationTrigger {
                return trigger.nextTriggerDate()
            }
            else {
                return nil
            }
        }
        
        return filteredDates.sorted().first
    }
}
