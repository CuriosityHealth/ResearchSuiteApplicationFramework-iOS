//
//  RSNotificationManager.swift
//  Breathe
//
//  Created by James Kizer on 11/21/17.
//  Copyright © 2017 Curiosity Health. All rights reserved.
//

import UIKit
import ReSwift
import UserNotifications

open class RSNotificationManager: NSObject, StoreSubscriber, UNUserNotificationCenterDelegate {
    
    weak var store: Store<RSState>?
    var lastState: RSState?
    
    static let minFetchInterval: TimeInterval = 1.0*60.0

    let notificationProcessors: [RSNotificationProcessor]
    
    public init(store: Store<RSState>, notificationProcessors: [RSNotificationProcessor]) {
        self.store = store
        self.notificationProcessors = notificationProcessors
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    public func newState(state: RSState) {
        
        //check for notifications being enabled
        guard let lastState = self.lastState else {
            self.lastState = state
            return
        }
        
        self.lastState = state
        
        //if first run, maybe check to see if notifications are enabled but shouldn't be
        //note than we can probably get a list of currently enabled notifications
        //only update this list on change as well as once per n minutes
        guard let _ = RSStateSelectors.pendingNotificationIdentifiers(state),
            let lastFetchTime = RSStateSelectors.lastFetchTime(state) else {
                self.store?.dispatch(RSActionCreators.fetchPendingNotificationIdentifiers())
                return
        }
        
        if lastFetchTime.addingTimeInterval(RSNotificationManager.minFetchInterval) < Date() {
            self.store?.dispatch(RSActionCreators.fetchPendingNotificationIdentifiers())
            return
        }
        
        guard !RSStateSelectors.isFetchingNotificationIdentifiers(state) else {
            return
        }

        let notifications = RSStateSelectors.notifications(state)
        self.processRecursively(
            notifications: notifications,
            state: state,
            lastState: lastState) { (shouldFetch) in
                if shouldFetch {
                    DispatchQueue.main.async {
                        self.store?.dispatch(RSActionCreators.fetchPendingNotificationIdentifiers())
                    }
                }
        }
        
    }

    private func processNotification(notification: RSNotification, state: RSState, lastState: RSState, callback: @escaping (Bool) -> ()) {
        //compute predicate to see whether or not notifications SHOULD be enabled
        
        guard let processor = self.processor(forNotification: notification),
            let pendingNotificationIdentifiers = RSStateSelectors.pendingNotificationIdentifiers(state) else {
            callback(false)
            return
        }
        let enabled: Bool = {
            //check for predicate and evaluate
            //if predicate exists and evaluates false, do not execute action
            if let predicate = notification.predicate {
                return RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
            }
            else {
                return true
            }
            
        }()
        
        //if notifications SHOULD NOT be enabled, filter pending notifications, disable remaining notifications
        if !enabled {
            
            let filteredIdentifiers = processor.identifierFilter(notification: notification, identifiers: pendingNotificationIdentifiers)
            if filteredIdentifiers.count > 0 {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: filteredIdentifiers)
                callback(true)
                return
            }
            else {
                callback(false)
                return
            }

        }
        //if notifications SHOULD be enabled
        else {
            
            //check with processor to see if we should update
            //if so, generate notification request
            if processor.shouldUpdate(notification: notification, state: state, lastState: state),
                let notificationRequest = processor.generateNotificationRequest(notification: notification, state: state, lastState: lastState) {
                
                UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { error in
                    callback(true)
                })
                return
                
            }
            else {
                callback(false)
                return
            }
        }
        
    }

    private func processRecursively(notifications: [RSNotification], state: RSState, lastState: RSState, callback: @escaping (Bool) -> ()) {
        
        let head: RSNotification = notifications.first!
        
        let tail = Array(notifications.dropFirst())
        if tail.count > 0 {
            self.processRecursively(notifications: tail, state: state, lastState: lastState, callback: { (shouldFetch) in
                
                print("shouldFetch is \(shouldFetch)")
                
                self.processNotification(notification: head, state: state, lastState: lastState, callback: { innerShouldFetch in
                    callback(shouldFetch || innerShouldFetch)
                })
                
            })
        }
        else {
            self.processNotification(notification: head, state: state, lastState: lastState, callback: callback)
        }
    }

    private func processor(forNotification: RSNotification) -> RSNotificationProcessor? {
        return self.notificationProcessors.first { $0.supportsType(type: forNotification.type) }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let date = response.notification.date
        let notificationID = response.notification.request.identifier
        let action = RSActionCreators.logNotificationInteraction(notificationID: notificationID, date: date)
        self.store?.dispatch(action)
        
        if let store = self.store {
            
            let notifications = RSStateSelectors.notifications(store.state)
            notifications.forEach { notification in
                
                //get processor for notification and check to see if the identifier matches the notfication
                guard let processor = self.processor(forNotification: notification),
                    processor.identifierFilter(notification: notification, identifiers: [notificationID]).count == 1,
                    let handlerActions = notification.handlerActions else {
                        return
                }
                
                RSActionManager.processActions(actions: handlerActions, context: ["notification": response.notification], store: store)
                
            }
        }
        
        completionHandler()
        
    }
    
//    static public func setNotification(identifier: String, components: DateComponents, title: String, body: String, completion: @escaping (Error?)->() ) {
//        
//        debugPrint("Setting notification: \(identifier): \(components)")
//        
//        let center = UNUserNotificationCenter.current()
//        
//        //The time components created by ResearchKit set year, month, day to 0
//        //this results in the trigger never firing
//        //create a new DateComponents object specifying only hour and minute
//        let selectedComponents = DateComponents(hour: components.hour, minute: components.minute)
//        
//        // Enable or disable features based on authorization
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.body = body
//        content.sound = UNNotificationSound.default()
//        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: selectedComponents, repeats: true)
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//        
//        center.add(request, withCompletionHandler: completion)
//        
//    }
//    
//    static public func cancelNotifications() {
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//    }
//    
//    static public func cancelNotificationsWithIdentifierPrefixedBy(prefix: String, pendingNotificationIdentifiers: [String]) {
//        let notificationsToCancel = pendingNotificationIdentifiers.filter { $0.hasPrefix(prefix) }
//        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationsToCancel)
//    }
//    
//    static public func cancelNotificationWithIdentifiers(identifiers: [String]) {
//        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
//    }
    
    static public func printPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (notificationRequests) in
            var debugString = "PENDING NOTIFICATINS\n"
            //            debugPrint("PENDING NOTIFICATINS")
            notificationRequests.forEach { notification in
                debugString.append("\(notification.debugDescription)\n")
                if let trigger: UNCalendarNotificationTrigger = notification.trigger as? UNCalendarNotificationTrigger,
                    let fireDate = trigger.nextTriggerDate() {
                    debugString.append("\(fireDate)\n")
                }
                else if let trigger: UNTimeIntervalNotificationTrigger = notification.trigger as? UNTimeIntervalNotificationTrigger,
                    let fireDate = trigger.nextTriggerDate() {
                    debugString.append("\(fireDate)\n")
                }
            }
            
            debugPrint(debugString)
        })
    }
    
    

}

