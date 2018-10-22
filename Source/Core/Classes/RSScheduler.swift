//
//  RSScheduler.swift
//  Pods
//
//  Created by James Kizer on 9/17/18.
//

import UIKit
import Gloss
import ReSwift

//how do we identify that an item has been interacted with?
//completed / completed time?


public enum RSScheduleEventState: String {
    case scheduled = "scheduled"
    case pending = "pending"
    case expired = "expired"
    case completed = "completed"
}

public protocol RSScheduleEvent: RSCollectionDataSourceElement, NSObjectProtocol {
    var identifier: String { get }
    var eventType: String { get }
    var startTime: Date { get }
    var duration: TimeInterval? { get }
    
    var completionTime: Date? { get }
    var priority: Int { get }
    var extraInfo: JSON? { get }
    
    var state: RSScheduleEventState { get }
    
    //state - these should be mutually exclusive
//    var expired: Bool { get }
    var completed: Bool { get }
//    var pending: Bool { get }
    
    var completedTaskRuns: [String]? { get }
    
}

extension RSScheduleEvent {
    
    public var state: RSScheduleEventState {
        
        //first, check for completed
        if self.completed {
            return .completed
        }
        
        //next, check for scheduled
        let now = Date()
        if self.startTime > now {
            return .scheduled
        }
        
        //next, check for expired
        //if no duration, can't expire
        //if now is later than start time + duration, event has expired
        if let duration = self.duration,
            now > self.startTime.addingTimeInterval(duration) {
            return .expired
        }
        
        //otherwise, considered pending
        else {
            return .pending
        }

    }
    
    //events have 4 states
    //scheduled - submitted, but start time is in the future
    //pending - runnable, start time is in past, not completed, not expired
    //expired - start time + duration is in the past, not completed
    //completed - event was executed
    
//    public var scheduled: Bool {
//        let now = Date()
//        return self.startTime > now
//    }
    
    //an event has expired iff
    //the current time is after (i.e., greater than) startTime + duration
    //the event is not completed
    //NOTE: an item can only exipre if it has a start time AND duration
//    public var expired: Bool {
//        if self.completed {
//            return false
//        }
//
//        if self.scheduled {
//            return false
//        }
//
//        let startTime = self.startTime
//
//        guard let duration = self.duration else {
//                return false
//        }
//
//        let now = Date()
//        return now > startTime.addingTimeInterval(duration)
//    }
    
    //an event is pending iff
    //the event is not completed
    //the event has no start time OR the event has a start time and it is currently after the start time
    //if the event has a start time, the event has NO duration OR the start time + duration is after now
//    public var pending: Bool {
//
//        if self.completed {
//            return false
//        }
//
//        if self.scheduled {
//            return false
//        }
//
//        if self.expired {
//            return false
//        }
//
//        let now = Date()
//
//        guard let duration = self.duration else {
//            //if the event has no duration, this means it cannot expire, thus is pending
//            return true
//        }
//
//        //otherwise, the event is pending if the expiration date is in the future
//        return now < startTime.addingTimeInterval(duration)
//    }
    
    public var primaryDate: Date? {
        return self.startTime
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "identifier" ~~> self.identifier,
            "eventType" ~~> self.eventType,
            Gloss.Encoder.encode(dateISO8601ForKey: "startTime")(self.startTime),
            "duration" ~~> self.duration,
            "completed" ~~> self.completed,
            Gloss.Encoder.encode(dateISO8601ForKey: "completionTime")(self.completionTime),
            "completedTaskRuns" ~~> self.completedTaskRuns,
            "priority" ~~> self.priority,
            "extraInfo" ~~> self.extraInfo,
            "state" ~~> self.state
            ])
    }
    
}

//NOTE: RSScheduler should probably be removed from this
//W
public typealias RSDashboardCellGenerator = (RSScheduler, Store<RSState>, RSState, UICollectionView, RSCollectionViewCellManager, RSDashboardAdaptorItem, IndexPath) -> RSCollectionViewCell?

public protocol RSDashboardAdaptorItemConvertible {
    func toDashboardAdaptorItem() -> RSDashboardAdaptorItem?
}

public protocol RSDashboardAdaptorItem {
    var identifier: String { get }
    var priority: Int { get }
    var shouldPresentItem: Bool { get }
    var generateCell: RSDashboardCellGenerator { get }
}

public class RSConcreteScheduleEvent: NSObject, RSScheduleEvent, RSScheduleEventBuilder {
    
    public static func createEvent(
        identifier: String,
        eventType: String,
        startTime: Date,
        duration: TimeInterval?,
        completed: Bool,
        completionTime: Date?,
        completedTaskRuns: [String]?,
        priority: Int,
        extraInfo: [String : Any]?) -> RSScheduleEvent {
        return RSConcreteScheduleEvent(
            identifier: identifier,
            eventType: eventType,
            startTime: startTime,
            duration: duration,
            completed: completed,
            completionTime: completionTime,
            completedTaskRuns: completedTaskRuns,
            priority: priority,
            extraInfo: extraInfo
        )
    }
    
    public static func copyEvent(event: RSScheduleEvent) -> RSScheduleEvent {
        
        return self.createEvent(
            identifier: event.identifier,
            eventType: event.eventType,
            startTime: event.startTime,
            duration: event.duration,
            completed: event.completed,
            completionTime: event.completionTime,
            completedTaskRuns: event.completedTaskRuns,
            priority: event.priority,
            extraInfo: event.extraInfo
        )
        
    }
    
    public init(
        identifier: String,
        eventType: String,
        startTime: Date,
        duration: TimeInterval?,
        completed: Bool,
        completionTime: Date?,
        completedTaskRuns: [String]?,
        priority: Int,
        extraInfo: [String : Any]?
        ) {
        
        self.identifier = identifier
        self.eventType = eventType
        self.startTime = startTime
        self.duration = duration
        self.completed = completed
        self.completionTime = completionTime
        self.completedTaskRuns = completedTaskRuns
        self.priority = priority
        self.extraInfo = extraInfo
        
    }
    
    
    public var identifier: String
    
    public var eventType: String
    
    public var startTime: Date
    
    public var duration: TimeInterval?
    
    public var completed: Bool
    public var completionTime: Date?
    public var completedTaskRuns: [String]?
    
    public var priority: Int
    
    public var extraInfo: [String : Any]?
    
}

public protocol RSScheduleEventConvertible {
    func toScheduleEvent(builder: RSScheduleEventBuilder.Type) -> RSScheduleEvent?
}

public protocol RSScheduleEventDecodable {
    init?(event: RSScheduleEvent)
}

public protocol RSScheduleEventBuilder {

    static func createEvent(
        identifier: String,
        eventType: String,
        startTime: Date,
        duration: TimeInterval?,
        completed: Bool,
        completionTime: Date?,
        completedTaskRuns: [String]?,
        priority: Int,
        extraInfo: [String: Any]?
        ) -> RSScheduleEvent
    
    static func copyEvent(event: RSScheduleEvent) -> RSScheduleEvent
    
}

public protocol RSSchedulerSubscriber: class {
    func newSchedulerEvents(scheduler: RSScheduler, events: [RSScheduleEvent], deletions: [Int], additions: [Int], modifications: [Int])
}

struct RSSchedulerSubscription {
    private(set) weak var subscriber: RSSchedulerSubscriber? = nil
}

//scheduler should be responsible for all current and future events
//based on the state of the system

public struct RSSchedulerEventChanges {
    
    public let deletions: [Int]
    public let additions: [Int]
    public let modifications: [Int]
    
}

public struct RSSchedulerEventUpdate {
    public let uuid: UUID
    public let events: [RSScheduleEvent]
    public let oldEvents: [RSScheduleEvent]
    public let changes: RSSchedulerEventChanges
    
    public static func initial() -> RSSchedulerEventUpdate {
        let changes = RSSchedulerEventChanges(deletions: [], additions: [], modifications: [])
        return RSSchedulerEventUpdate(uuid: UUID(), events: [], oldEvents: [], changes: changes)
    }
    
}

public protocol RSSchedulerSeries {
    static var monitoredValues: [String] { get }
    static func generateEvents(schedulerDatabase: RSSchedulerDatabase, state: RSState, extrapolationDuration: TimeInterval) -> [RSScheduleEvent]
}

//it can either adopt or emit objects that adopt the dashbaord adaptor protocol
//NOTE: this distinction will be made depending upon whether the object adopting
//needs to keep a reference to the collection view. Maybe better to keep all this in the state?
// definately need to update downstream
open class RSScheduler: NSObject, StoreSubscriber {
    
    
//    private var _events: [RSScheduleEvent] = []
    public var events: [RSScheduleEvent] {
        guard let state = self.lastState else {
            return []
        }
        
        return RSStateSelectors.getSchedulerEventUpdate(state)?.events ?? []
    }
    
    var subscriptions: [RSSchedulerSubscription] = []
    private var lastState: RSState?
    
    open func newState(state: RSState) {
        
        guard let lastState = self.lastState,
            RSStateSelectors.isConfigurationCompleted(state) else {
                self.lastState = state
                return
        }
        
        //check for initial load
        if RSStateSelectors.getSchedulerEventUpdate(state) == nil {
            self.reloadSchedule(state: state)
        }
        else if self.shouldReloadSchedule(state: state, lastState: lastState) {
            self.reloadSchedule(state: state)
        }
        
        self.lastState = state
    }
    
    open func shouldReloadSchedule(state: RSState, lastState: RSState) -> Bool {
        return false
    }
    
    open func reloadSchedule(state: RSState?) {
        guard let state = state ?? self.lastState else {
            return
        }
        let events = self.loadEvents(state: state)
        self.setEvents(events: events, state: state)
    }
    
    open func loadEvents(state: RSState) -> [RSScheduleEvent] {
        return []
    }
    
    private func _isNewSubscriber(subscriber: RSSchedulerSubscriber) -> Bool {
        let contains = subscriptions.contains(where: { $0.subscriber === subscriber })
        
        if contains {
            print("Scheduler subscriber is already added, ignoring.")
            return false
        }
        
        return true
    }
    
    
    open func subscribe(_ subscriber: RSSchedulerSubscriber) {
        
        if !_isNewSubscriber(subscriber: subscriber) { return }
        
        let subscription = RSSchedulerSubscription(subscriber: subscriber)
        
        self.subscriptions = self.subscriptions + [subscription]
        
        if let state = self.lastState {
            let events = RSStateSelectors.getSchedulerEventUpdate(state)?.events ?? []
            subscriber.newSchedulerEvents(scheduler: self, events: events, deletions: [], additions: [], modifications: [])
        }
        
    }
    
    open func unsubscribe(_ subscriber: RSSchedulerSubscriber) {
        self.subscriptions = self.subscriptions.filter { return $0.subscriber === subscriber }
    }
    
    open func computeChanges(newEvents: [RSScheduleEvent], oldEvents: [RSScheduleEvent]) -> RSSchedulerEventChanges? {
    
        
        //NOTE: This does not currently handle ordering changes (i.e., treats everything as sets)
        //if ordering matters, probably want to compute after the fact
        
        let oldEventsEnumerated = oldEvents.enumerated()
        let oldEventDict:[String: (Int, RSScheduleEvent)] = Dictionary.init(
            uniqueKeysWithValues: oldEventsEnumerated.map { ($0.element.identifier, $0) }
        )
        
        let newEventsEnumerated = newEvents.enumerated()
        let newEventDict:[String: (Int, RSScheduleEvent)] = Dictionary.init(
            uniqueKeysWithValues: newEventsEnumerated.map { ($0.element.identifier, $0) }
        )
        
        //check to see which items in old events is not in new events
        let deletions: [Int] = oldEventsEnumerated
            //            .filter { !newEventIdentifierSet.contains($0.element.identifier) }
            .filter { newEventDict[$0.element.identifier] == nil }
            .map { $0.offset }
        
        //vice versa
        let additions: [Int] = newEventsEnumerated
            //            .filter { !oldEventIdentifierSet.contains($0.element.identifier) }
            .filter { oldEventDict[$0.element.identifier] == nil }
            .map { $0.offset }
        
        //Seems like we need to list the item indicies in the old collection per link here:
        //https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW9
        
    
        let itemsInBothLists: [((Int,RSScheduleEvent),  (Int,RSScheduleEvent))] = oldEventsEnumerated
            .compactMap { (oldEventPair) -> ((Int,RSScheduleEvent),  (Int,RSScheduleEvent))? in
                
                guard let newEventPair = newEventDict[oldEventPair.element.identifier] else {
                    return nil
                }
                
                return (oldEventPair, newEventPair)
        }
        
        let modifications: [Int] = itemsInBothLists
            .filter { !($0.0.1.isEqual($0.1.1)) }
            .map { $0.0.0 }
        
//        let nonModifications = itemsInBothLists
//            .filter { $0.0.1.isEqual($0.1.1) }
//        
//        //look for reordering among nonModifications
//        let nonModificationsOld: [(Int,RSScheduleEvent)] = nonModifications.map { $0.0 }
//        let nonModificationsNew: [(Int,RSScheduleEvent)] = nonModifications.map { $0.1 }
        
//        return RSSchedulerEventChanges(deletions: deletions, additions: additions, modifications: modifications)
        if deletions.count > 0 ||
            additions.count > 0 ||
            modifications.count > 0 {
            return RSSchedulerEventChanges(deletions: deletions, additions: additions, modifications: modifications)
        }

        else {
            return nil
        }
    }
    
    open func setEvents(events: [RSScheduleEvent], state: RSState) {
        
        let oldEvents = RSStateSelectors.getSchedulerEventUpdate(state)?.events ?? []
        
        if let changes = self.computeChanges(newEvents: events, oldEvents: oldEvents),
            let store = RSApplicationDelegate.appDelegate.store {
            
            let scheduleEventUpdate = RSSchedulerEventUpdate(
                uuid: UUID(),
                events: events,
                oldEvents: oldEvents,
                changes: changes
            )
            
            store.dispatch(RSActionCreators.updateScheduler(schedulerEventUpdate: scheduleEventUpdate))
            
            let subscriptions = self.subscriptions
            subscriptions.forEach { (subscription) in
                subscription.subscriber?.newSchedulerEvents(
                    scheduler: self,
                    events: events,
                    deletions: changes.deletions,
                    additions: changes.additions,
                    modifications: changes.modifications
                )
            }
        }
        
    }
    
    open func markEventCompleted(eventId: String, taskRuns: [UUID], state: RSState) {
        
    }

}
