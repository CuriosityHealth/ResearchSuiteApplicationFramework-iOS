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

    public typealias RSNotificationProcessor = (RSState, RSState, Store<RSState>?, @escaping (Bool)->()) -> Swift.Void
    
    public init(store: Store<RSState>) {
        self.store = store
        super.init()
        UNUserNotificationCenter.current().delegate = self
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

        self.processRecursively(
            processors: self.notificationProcessors,
            state: state,
            lastState: lastState,
            store: store) { (shouldFetch) in
                if shouldFetch {
                    DispatchQueue.main.async {
                        self.store?.dispatch(RSActionCreators.fetchPendingNotificationIdentifiers())
                    }
                }
        }
        
        
    }
    
    private func processRecursively(processors: [RSNotificationProcessor], state: RSState, lastState: RSState, store: Store<RSState>?, callback: @escaping (Bool) -> ()) {
        
        let head: RSNotificationProcessor = processors.first!
        
        let tail = Array(processors.dropFirst())
        if tail.count > 0 {
            
            self.processRecursively(processors: tail, state: state, lastState: lastState, store: store, callback: { (shouldFetch) in
                
                print("shouldFetch is \(shouldFetch)")
                
                head(state, lastState, store, { innerShouldFetch in
                    callback(shouldFetch || innerShouldFetch)
                })
                
            })
            
            
        }
        else {
            head(state, lastState, store, callback)
        }
    }
    
    open var notificationProcessors: [RSNotificationProcessor] {
        return []
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let date = response.notification.date
        let notificationID = response.notification.request.identifier
        let action = RSActionCreators.logNotificationInteraction(notificationID: notificationID, date: date)
        self.store?.dispatch(action)
        
        if let store = self.store {
            let handlers = RSStateSelectors.notificationHandlers(store.state)
            handlers.forEach { (handler) in
                if notificationID.starts(with: handler.identifier) {
                    RSActionManager.processActions(actions: handler.handlerActions, context: ["notification": response.notification], store: store)
                }
            }
        }
        
        completionHandler()
        
    }
    
    static public func setNotification(identifier: String, components: DateComponents, title: String, body: String, completion: @escaping (Error?)->() ) {
        
        debugPrint("Setting notification: \(identifier): \(components)")
        
        let center = UNUserNotificationCenter.current()
        
        //The time components created by ResearchKit set year, month, day to 0
        //this results in the trigger never firing
        //create a new DateComponents object specifying only hour and minute
        let selectedComponents = DateComponents(hour: components.hour, minute: components.minute)
        
        // Enable or disable features based on authorization
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: selectedComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: completion)
        
    }
    
    static public func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    static public func cancelNotificationsWithIdentifierPrefixedBy(prefix: String, pendingNotificationIdentifiers: [String]) {
        let notificationsToCancel = pendingNotificationIdentifiers.filter { $0.hasPrefix(prefix) }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationsToCancel)
    }
    
    static public func cancelNotificationWithIdentifiers(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
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

