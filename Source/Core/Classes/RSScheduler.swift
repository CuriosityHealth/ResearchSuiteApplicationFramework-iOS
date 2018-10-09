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

public protocol RSScheduleEvent: RSCollectionDataSourceElement {
    var identifier: String { get }
    var eventType: String { get }
    var startTime: Date? { get }
    var duration: TimeInterval? { get }
    
    var completionTime: Date? { get }
    var persistent: Bool { get }
    var priority: Int { get }
    var extraInfo: JSON? { get }
    
    //state - these should be mutually exclusive
//    var expired: Bool { get }
    var completed: Bool { get }
//    var pending: Bool { get }
}

extension RSScheduleEvent {
    
    //an event has expired iff
    //the current time is after (i.e., greater than) startTime + duration
    //the event is not completed
    //NOTE: an item can only exipre if it has a start time AND duration
    public var expired: Bool {
        if self.completed {
            return false
        }
        
        guard let startTime = self.startTime,
            let duration = self.duration else {
                return false
        }
        
        let now = Date()
        
        return now > startTime.addingTimeInterval(duration)
    }
    
    //an event is pending iff
    //the event is not completed
    //the event has no start time OR the event has a start time and it is currently after the start time
    //if the event has a start time, the event has NO duration OR the start time + duration is after now
    public var pending: Bool {
        if self.completed {
            return false
        }
        
        guard let startTime = self.startTime else {
            //if the event has no start time, the event is considered pending
            return true
        }
        
        let now = Date()
        
        //if startTime is after the current time (i.e., the start time is in the future)
        //the event is not pending
        if startTime > now {
            return false
        }
        
        guard let duration = self.duration else {
            //if the event has no duration, this means it cannot expire, thus is pending
            return true
        }
        
        //otherwise, the event is pending if the expiration date is in the future
        return now < startTime.addingTimeInterval(duration)
    }
    
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
            "persistent" ~~> self.persistent,
            "priority" ~~> self.priority,
            "extraInfo" ~~> self.extraInfo,
            "expired" ~~> self.expired,
            "pending" ~~> self.pending,
            ])
    }
    
}

public typealias RSDashboardCellGenerator = (RSScheduler, Store<RSState>, RSState, UICollectionView, RSCollectionViewCellManager, RSDashboardAdaptorItem, IndexPath) -> RSCollectionViewCell?

public protocol RSDashboardAdaptorItemConvertible {
    func toDashboardAdaptorItem() -> RSDashboardAdaptorItem?
}

public protocol RSDashboardAdaptorItem {
    var identifier: String { get }
    var priority: Int { get }
    var generateCell: RSDashboardCellGenerator { get }
}

public struct RSConcreteScheduleEvent: RSScheduleEvent, RSScheduleEventBuilder {
    
    
    
    public static func createEvent(identifier: String, eventType: String, startTime: Date?, duration: TimeInterval?, completed: Bool, completionTime: Date?, persistent: Bool, priority: Int, extraInfo: [String : Any]?) -> RSScheduleEvent {
        return RSConcreteScheduleEvent(
            identifier: identifier,
            eventType: eventType,
            startTime: startTime,
            duration: duration,
            completed: completed,
            completionTime: completionTime,
            persistent: persistent,
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
            persistent: event.persistent,
            priority: event.priority,
            extraInfo: event.extraInfo
        )
        
    }
    
    public init(
        identifier: String,
        eventType: String,
        startTime: Date?,
        duration: TimeInterval?,
        completed: Bool,
        completionTime: Date?,
        persistent: Bool,
        priority: Int,
        extraInfo: [String : Any]?
        ) {
        
        self.identifier = identifier
        self.eventType = eventType
        self.startTime = startTime
        self.duration = duration
        self.completed = completed
        self.completionTime = completionTime
        self.persistent = persistent
        self.priority = priority
        self.extraInfo = extraInfo
        
    }
    
    
    public var identifier: String
    
    public var eventType: String
    
    public var startTime: Date?
    
    public var duration: TimeInterval?
    
    public var completed: Bool
    public var completionTime: Date?
    
    public var persistent: Bool
    
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
        startTime: Date?,
        duration: TimeInterval?,
        completed: Bool,
        completionTime: Date?,
        persistent: Bool,
        priority: Int,
        extraInfo: [String: Any]?
        ) -> RSScheduleEvent
    
    static func copyEvent(event: RSScheduleEvent) -> RSScheduleEvent
    
}

public protocol RSSchedulerSubscriber: class {
    func newSchedulerEvents(scheduler: RSScheduler, events: [RSScheduleEvent], deletions: [Int], additions: [Int])
}

struct RSSchedulerSubscription {
    private(set) weak var subscriber: RSSchedulerSubscriber? = nil
}

//scheduler should be responsible for all current and future events
//based on the state of the system

//it can either adopt or emit objects that adopt the dashbaord adaptor protocol
//NOTE: this distinction will be made depending upon whether the object adopting
//needs to keep a reference to the collection view. Maybe better to keep all this in the state?
// definately need to update downstream
open class RSScheduler: NSObject {
    
    private var _events: [RSScheduleEvent] = []
    public var events: [RSScheduleEvent] {
        return self._events
    }
    
    var subscriptions: [RSSchedulerSubscription] = []
    
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
        
        subscriber.newSchedulerEvents(scheduler: self, events: self.events, deletions: [], additions: [])
    }
    
    open func unsubscribe(_ subscriber: RSSchedulerSubscriber) {
        self.subscriptions = self.subscriptions.filter { return $0.subscriber === subscriber }
    }
    
    open func setEvents(events: [RSScheduleEvent]) {
        
        let oldEventsEnumerated = self._events.enumerated()
        let oldEventIdentifierSet = Set(self._events.map({$0.identifier}))
        
        let newEventsEnumerated = events.enumerated()
        let newEventIdentifierSet = Set(events.map({$0.identifier}))
        
        //check to see which items in old events is not in new events
        let deletions: [Int] = oldEventsEnumerated
            .filter { !newEventIdentifierSet.contains($0.element.identifier) }
            .map { $0.offset }
        
        //vice versa
        let additions: [Int] = newEventsEnumerated
            .filter { !oldEventIdentifierSet.contains($0.element.identifier) }
            .map { $0.offset }
        
        self._events = events
        let subscriptions = self.subscriptions
        subscriptions.forEach { (subscription) in
            subscription.subscriber?.newSchedulerEvents(
                scheduler: self,
                events: self.events,
                deletions: deletions,
                additions: additions
            )
        }
        
    }
    
    open func markEventCompleted(event: RSScheduleEvent) {
        
    }

}
