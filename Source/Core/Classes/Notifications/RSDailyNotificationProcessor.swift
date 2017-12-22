//
//  RSDailyNotificationProcessor.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/21/17.
//

import UIKit
import Gloss
import UserNotifications

open class RSDailyNotificationProcessor: NSObject, RSNotificationProcessor {
    
    public func supportsType(type: String) -> Bool {
        return type == "daily"
    }
    
    static private func enabledDays(dailyNotification: RSDailyNotification, pendingNotificationIdentifiers: [String]) -> [Int] {
        let dailyNotificationIdentifiers = pendingNotificationIdentifiers.filter { $0.hasPrefix(dailyNotification.identifier) }
        let dailyNotificationDays: [Int] = dailyNotificationIdentifiers.flatMap { identifier in
            let strHour = identifier.replacingOccurrences(of: dailyNotification.identifier, with: "")
            return Int(strHour)
        }
        
        return dailyNotificationDays
    }
    
    public func shouldUpdate(notification: RSNotification, state: RSState, lastState: RSState) -> Bool {
        
        //get daily notification and pending notifications
        guard let dailyNotification = RSDailyNotification(json: notification.json),
            let pendingNotificationIdentifiers = RSStateSelectors.pendingNotificationIdentifiers(state) else {
                return false
        }
        
        //if notification does not include weekdays json, it should be enabled every day
        let weekdaysOpt: [Int]? = {
            if let weekdaysJSON = dailyNotification.weekdays,
                let weekdays = RSValueManager.processValue(jsonObject: weekdaysJSON, state: state, context: [:])?.evaluate() as? [Int] {
                return weekdays
            }
            else {
                return [1,2,3,4,5,6,7]
            }
        }()
        
        guard let daysThatShouldBeEnabled = weekdaysOpt else {
            return false
        }
        
        let enabledDays = RSDailyNotificationProcessor.enabledDays(dailyNotification: dailyNotification, pendingNotificationIdentifiers: pendingNotificationIdentifiers)
        
        if Set(daysThatShouldBeEnabled) != Set(enabledDays) {
            return true
        }
        
        //otherwise, check monitored values to see if they changed between state and last state
        return dailyNotification.monitoredValues.reduce(false) { (acc, monitoredValue) -> Bool in
            return acc || RSValueManager.valueChanged(jsonObject: monitoredValue, state: state, lastState: lastState, context: [:])
        }
    }
    
    public func generateNotificationRequest(notification: RSNotification, state: RSState, lastState: RSState) -> UNNotificationRequest? {
        guard let dailyNotification = RSDailyNotification(json: notification.json),
            let pendingNotificationIdentifiers = RSStateSelectors.pendingNotificationIdentifiers(state) else {
                return nil
        }
        
        //if notification does not include weekdays json, it should be enabled every day
        let weekdaysOpt: [Int]? = {
            if let weekdaysJSON = dailyNotification.weekdays,
                let weekdays = RSValueManager.processValue(jsonObject: weekdaysJSON, state: state, context: [:])?.evaluate() as? [Int] {
                return weekdays
            }
            else {
                return [1,2,3,4,5,6,7]
            }
        }()
        
        guard let daysThatShouldBeEnabled = weekdaysOpt,
            let time = RSValueManager.processValue(jsonObject: dailyNotification.time, state: state, context: [:])?.evaluate() as? DateComponents else {
            return nil
        }
        
        let enabledDays = RSDailyNotificationProcessor.enabledDays(dailyNotification: dailyNotification, pendingNotificationIdentifiers: pendingNotificationIdentifiers)
        
        let enabledSet = Set(enabledDays)
        let shouldBeEnabledSet = Set(daysThatShouldBeEnabled)
        
        if let newDay = shouldBeEnabledSet.subtracting(enabledSet).first {
            
            let dateComponents = DateComponents(hour: time.hour, minute: time.minute, weekday: newDay)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Enable or disable features based on authorization
            let content = UNMutableNotificationContent()
            content.title = dailyNotification.title
            content.body = dailyNotification.body
            content.sound = UNNotificationSound.default()
            
            let request = UNNotificationRequest(
                identifier: "\(dailyNotification.identifier)\(newDay)",
                content: content,
                trigger: trigger
            )
            
            return request
            
        }
        
        return nil
    }
    
    //closure returns true to signify that the notification should be canceled
    public func shouldCancelFilter(notification: RSNotification, state: RSState) -> (String) -> Bool {
        guard let dailyNotification = RSDailyNotification(json: notification.json) else {
                return { _ in false }
        }
        
        //if an identifier is specified that should not be enabled, return true
        let weekdaysOpt: [Int]? = {
            if let weekdaysJSON = dailyNotification.weekdays,
                let weekdays = RSValueManager.processValue(jsonObject: weekdaysJSON, state: state, context: [:])?.evaluate() as? [Int] {
                return weekdays
            }
            else {
                return [1,2,3,4,5,6,7]
            }
        }()
        
        guard let daysThatShouldBeEnabled = weekdaysOpt else {
            return { _ in false }
        }
        
        let notificationsThatShouldBeEnabled = daysThatShouldBeEnabled.map { "\(dailyNotification.identifier)\($0)" }
        
        return { !notificationsThatShouldBeEnabled.contains($0) }
        
    }
    
    //closure returns true to signify that it own the notification
    public func identifierFilter(notification: RSNotification) -> (String) -> Bool {
        return { $0.hasPrefix(notification.identifier) }
    }
    
    public func nextTriggerDate(notification: RSNotification, state: RSState) -> Date? {
        
        guard let notificationRequests = RSStateSelectors.pendingNotifications(state) else {
            return nil
        }
        
        let filter = identifierFilter(notification: notification)
        let filteredNotificationRequests:[UNNotificationRequest] = notificationRequests.filter( { filter($0.identifier) } )
        let filteredDates: [Date] = filteredNotificationRequests.flatMap { (notificationRequest) -> Date? in
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
