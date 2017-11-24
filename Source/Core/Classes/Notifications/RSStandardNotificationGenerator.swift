//
//  RSStandardNotificationGenerator.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/23/17.
//

import UIKit
import Gloss
import UserNotifications

open class RSStandardNotificationGenerator: NSObject, RSNotificationGenerator {
    public func supportsType(type: String) -> Bool {
        return type == "standard"
    }

    public func shouldUpdate(jsonObject: JSON, state: RSState, lastState: RSState) -> Bool {
        guard let descriptor = RSStandardNotification(json: jsonObject) else {
            return false
        }
        
        //check monitored values to see if they changed between state and last state
        return descriptor.monitoredValues.reduce(false) { (acc, monitoredValue) -> Bool in
            return acc || RSValueManager.valueChanged(jsonObject: jsonObject, state: state, lastState: lastState, context: [:])
        }
        
    }
    
    private func generateInitialFireInterval(afterDate: Date?, timeInterval: TimeInterval?, dateComopnents: DateComponents?) -> TimeInterval? {
        
        let startDate:Date = afterDate ?? Date()
        let computedTimeInterval: TimeInterval = timeInterval ?? 0.0
        assert(computedTimeInterval >= 0)
        
        if let components = dateComopnents {
            let calendar = Calendar(identifier: .gregorian)
            if let fireDate = calendar.nextDate(after: startDate.addingTimeInterval(computedTimeInterval), matching: components, matchingPolicy: .strict) {
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
    public func generateNotificationRequest(jsonObject: JSON, state: RSState, lastState: RSState) -> UNNotificationRequest? {
        guard let descriptor = RSStandardNotification(json: jsonObject) else {
            return nil
        }
        
        if let initialFire = descriptor.initialFire {
            
            let afterDate: Date? = {
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
            
            guard let delayInterval = self.generateInitialFireInterval(afterDate: afterDate, timeInterval: timeInterval, dateComopnents: dateComponents) else {
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
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: repeatInterval, repeats: true)
                
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
            
        }
        
        return nil
    }
    
    public func identifierFilter(jsonObject: JSON, identifiers: [String]) -> [String] {
        guard let descriptor = RSStandardNotification(json: jsonObject) else {
            return []
        }
        
        return [descriptor.identifier]
    }
}
