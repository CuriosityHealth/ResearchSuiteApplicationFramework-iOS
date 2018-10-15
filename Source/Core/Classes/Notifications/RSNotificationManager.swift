//
//  RSNotificationManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/21/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import UserNotifications

public protocol RSNotificationConverter {
    var notificationRequestIdentifiers: [String] { get }
    func generateNotificationRequests(state: RSState) -> [UNNotificationRequest]?
    func hasPendingNotification(state: RSState) -> Bool
}

public protocol RSNotificationResponseHandler {
    static func canHandleNotificationResponse(notificationResponse: UNNotificationResponse) -> Bool
    static func handleNotificationResponse(notificationResponse: UNNotificationResponse, store: Store<RSState>)
}

extension UNUserNotificationCenter {
    
    //A, B, C
    //head = A, tail = [B,C]
    //calls add([B,C], completionA = Add(A), followed by completion
    //head = B, tail = [C]
    //calls add([C], completionB = Add(B), followed by completionA
    //head = C, tail = []
    //calls add([]), completionC = Add(C), followed by completion B
    //head = nil, calls completionC
    open func add(_ requests: [UNNotificationRequest], withCompletionHandler completionHandler: ((Error?) -> Void)? = nil) {
        
        if let head = requests.first {
            let tail = Array(requests.dropFirst())
            self.add(tail) { (tailError) in
                self.add(head) { (headError) in
                    completionHandler?(headError ?? tailError)
                }
            }
        }
        else {
            completionHandler?(nil)
        }
        
    }
}

open class RSNotificationManager: NSObject, StoreSubscriber, UNUserNotificationCenterDelegate {
    
    weak var store: Store<RSState>?
    var lastState: RSState?
    let legacySupport: Bool
    
    static let minFetchInterval: TimeInterval = 1.0*60.0

    let notificationProcessors: [RSNotificationProcessor]
    let notificationResponseHandlers: [RSNotificationResponseHandler.Type]
    
    public init(store: Store<RSState>, notificationResponseHandlers: [RSNotificationResponseHandler.Type], legacySupport: Bool, notificationProcessors: [RSNotificationProcessor]) {
        self.store = store
        self.notificationProcessors = notificationProcessors
        self.notificationResponseHandlers = notificationResponseHandlers
        self.legacySupport = legacySupport
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
        
        //there is an issue here
        //if we update last state, but we then go fetch the pending notifications
        //then it's possible that the state changes do not get propagated to notifications
        //hold off on setting last state, moved below
//        self.lastState = state
        
        guard RSStateSelectors.isConfigurationCompleted(state) else {
            return
        }
        
        //if first run, maybe check to see if notifications are enabled but shouldn't be
        //note than we can probably get a list of currently enabled notifications
        //only update this list on change as well as once per n minutes
        guard let pendingNotificationIdentifiers = RSStateSelectors.pendingNotificationIdentifiers(state),
            let lastFetchTime = RSStateSelectors.lastFetchTime(state) else {
                self.store?.dispatch(RSActionCreators.fetchPendingNotifications())
                return
        }
        
        if lastFetchTime.addingTimeInterval(RSNotificationManager.minFetchInterval) < Date() {
            self.store?.dispatch(RSActionCreators.fetchPendingNotifications())
            return
        }
        
        guard !RSStateSelectors.isFetchingNotifications(state) else {
            return
        }
        
        self.lastState = state
        
        if self.legacySupport {
            self.processLegacyNotifications(
                state: state,
                lastState: lastState,
                pendingNotificationIdentifiers: pendingNotificationIdentifiers
            )
        }
        else {
            self.processScheduleEventNotifications(state: state, lastState: lastState, pendingNotificationIdentifiers: Set(pendingNotificationIdentifiers))
        }

    }
    
    private func processScheduleEventNotifications(state: RSState, lastState: RSState, pendingNotificationIdentifiers: Set<String>) {
        
        var shouldFetchNotifications = false
        //if there are changes in schedule between state and last state, update notifications
        let oldSchedule = RSStateSelectors.getSchedulerEventUpdate(lastState)
        let newSchedule = RSStateSelectors.getSchedulerEventUpdate(state)
        
        //NOTE: This method is not called until after initial request fetching
        //We need to ensure that the below happens during the initial load
        //Actually, it looks like this will get called with the initial state of the system
        //(i.e., see that lastState.iteration == 0)
        if oldSchedule.uuid != newSchedule.uuid {
            //get deleted + modified events
            let deletedAndModifiedIndices = newSchedule.changes.deletions + newSchedule.changes.modifications
            let deletedAndModifiedEvents = deletedAndModifiedIndices.map { newSchedule.oldEvents[$0] }
            
            //check to see if they support notifications
            let notificationConvertersToCancel = deletedAndModifiedEvents.compactMap { $0 as? RSNotificationConverter }
            //if so, generate ID's and remove them, provided that they are in the list of pending notificaitons
            let identifiersToCancel: [String] = notificationConvertersToCancel
                .flatMap { $0.notificationRequestIdentifiers }
                .filter { pendingNotificationIdentifiers.contains($0) }
            
            if identifiersToCancel.count > 0 {
                shouldFetchNotifications = true
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
            }
            
            let modifiedEvents:[RSScheduleEvent] = {
                //modification indicies map to old events, so we need to pull these from the oldSchedule
                if newSchedule.changes.modifications.count > 0 {
                    let modificationIdentifiers = newSchedule.changes.modifications.map { newSchedule.oldEvents[$0].identifier }
                    let newEventDict: [String: RSScheduleEvent] =  Dictionary.init(uniqueKeysWithValues: newSchedule.events.map { ($0.identifier, $0) })
                    let newlyModifiedEvents = modificationIdentifiers.compactMap { newEventDict[$0] }
                    return newlyModifiedEvents
                }
                else {
                    return []
                }
            }()
            
            let addedEvents:[RSScheduleEvent] = newSchedule.changes.additions.map { newSchedule.events[$0] }
            
            let notificationRequests: [UNNotificationRequest] = (addedEvents + modifiedEvents)
                .compactMap { $0 as? RSNotificationConverter }
                .compactMap { $0.generateNotificationRequests(state: state) }
                .flatMap { $0 }
            
            if notificationRequests.count > 0 {
                //need to do this recursively due to notification center call
                UNUserNotificationCenter.current().add(notificationRequests) { (error) in
                    DispatchQueue.main.async {
                        self.store?.dispatch(RSActionCreators.fetchPendingNotifications())
                        RSNotificationManager.printPendingNotifications()
                    }
                }
            }
            else {
                if shouldFetchNotifications {
                    self.store?.dispatch(RSActionCreators.fetchPendingNotifications())
                }
            }
        
        }
        
    }

    private func processLegacyNotifications(state: RSState, lastState: RSState, pendingNotificationIdentifiers: [String]) {
        
        //Legacy Notifications
        let notifications = RSStateSelectors.notifications(state)
        
        //we should proabbly prune orphaned notifications here
        //i.e., to account for the case where there are enabled notifications but no RSNotification in the store
        //take all pending notification identifiers, filter by all configured notifications
        
//        //how might we delay this until the data source has a chance to load?
//        let identifiersToCancel: [String] = notifications.reduce(pendingNotificationIdentifiers) { (remainingPendingNotificationIdentifiers, notification) -> [String] in
//            let processor = self.processor(forNotification: notification)!
//            let filterfunction = processor.identifierFilter(notification: notification)
//            return remainingPendingNotificationIdentifiers.filter({ (identifier) -> Bool in
//                return !filterfunction(identifier)
//            })
//
//        }
//
//        if identifiersToCancel.count > 0 {
//            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
//        }
        
        
        guard notifications.count > 0 else {
            return
        }
        
        self.processRecursively(
            notifications: notifications,
            state: state,
            lastState: lastState) { (shouldFetch) in
                if shouldFetch {
                    DispatchQueue.main.async {
                        self.store?.dispatch(RSActionCreators.fetchPendingNotifications())
                    }
                }
        }
        
    }
    
    public func nextTriggerDate(notification: RSNotification, state: RSState) -> Date? {
        guard let processor = self.processor(forNotification: notification) else {
                return nil
        }

        return processor.nextTriggerDate(notification: notification, state: state)
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
                return RSPredicateManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
            }
            else {
                return true
            }
            
        }()
        
        //if notifications SHOULD NOT be enabled, filter pending notifications, disable remaining notifications
        if !enabled {
            
            let filteredIdentifiers = pendingNotificationIdentifiers.filter(processor.identifierFilter(notification: notification))
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
            var shouldRefresh = false
            let identifiersToCancel = pendingNotificationIdentifiers.filter(processor.identifierFilter(notification: notification))
                .filter(processor.shouldCancelFilter(notification: notification, state: state))
            if identifiersToCancel.count > 0 {
                shouldRefresh = true
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
            }
            
            //check with processor to see if we should update
            //if so, generate notification request
            if processor.shouldUpdate(notification: notification, state: state, lastState: lastState),
                let notificationRequest = processor.generateNotificationRequest(notification: notification, state: state, lastState: lastState) {
                
                UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { error in
                    callback(true)
                })
                return
                
            }
            else {
                callback(shouldRefresh)
                return
            }
        }
        
    }

    private func processRecursively(notifications: [RSNotification], state: RSState, lastState: RSState, callback: @escaping (Bool) -> ()) {
        
        assert(notifications.count > 0, "Notifications array must not be empty")
        let head: RSNotification = notifications.first!
        
        let tail = Array(notifications.dropFirst())
        if tail.count > 0 {
            self.processRecursively(notifications: tail, state: state, lastState: lastState, callback: { (shouldFetch) in
                
                //things that this calls must be only touched from main thread
                DispatchQueue.main.async {
                    self.processNotification(notification: head, state: state, lastState: lastState, callback: { innerShouldFetch in
                        callback(shouldFetch || innerShouldFetch)
                    })
                }
                
            })
        }
        else {
            self.processNotification(notification: head, state: state, lastState: lastState, callback: callback)
        }
    }

    private func processor(forNotification: RSNotification) -> RSNotificationProcessor? {
        return self.notificationProcessors.first { $0.supportsType(type: forNotification.type) }
    }
    
    private func handleLegacyNotification(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) {
        
        let date = response.notification.date
        let notificationID = response.notification.request.identifier
        let action = RSActionCreators.logNotificationInteraction(notificationID: notificationID, date: date)
        self.store?.dispatch(action)
        
        if let store = self.store {
            
            let notifications = RSStateSelectors.notifications(store.state)
            notifications.forEach { notification in
                
                //get processor for notification and check to see if the identifier matches the notfication
                guard let processor = self.processor(forNotification: notification),
                    [notificationID].filter(processor.identifierFilter(notification: notification)).count == 1,
                    let handlerActions = notification.handlerActions else {
                        return
                }
                
                store.processActions(actions: handlerActions, context: ["notification": response.notification], store: store)
                
            }
        }
    }
    
    private func handleScheduleEventNotification(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) {
        
        //log notification
        let date = response.notification.date
        let notificationID = response.notification.request.identifier
        let action = RSActionCreators.logNotificationInteraction(notificationID: notificationID, date: date)
        self.store?.dispatch(action)
        
        if let store = self.store,
            let notificationResponseHandler = self.notificationResponseHandlers.first(where: { $0.canHandleNotificationResponse(notificationResponse: response) }) {
            notificationResponseHandler.handleNotificationResponse(notificationResponse: response, store: store)
        }
        
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if self.legacySupport {
            self.handleLegacyNotification(center, didReceive: response)
        }
        else {
            self.handleScheduleEventNotification(center, didReceive: response)
        }
        
        completionHandler()
        
    }
    
    static public func setNotification(identifier: String, components: DateComponents, title: String, body: String, completion: @escaping (Error?)->() ) {
        
//        debugPrint("Setting notification: \(identifier): \(components)")
        
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
    static public func cancelNotificationWithIdentifiers(_ identifiers: [String]) {
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

