//
//  RSRealmScheduleEvent.swift
//  Pods
//
//  Created by James Kizer on 9/19/18.
//

import UIKit
import RealmSwift
import Realm
import Gloss

open class RSRealmScheduleEvent: Object, RSScheduleEvent, RSScheduleEventBuilder {

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
        
        let event = RSRealmScheduleEvent()
        event.identifier = identifier
        event.eventType = eventType
        event.startTime = startTime
        event.duration = duration
        event.completed = completed
        event.completionTime = completionTime
        event.completedTaskRuns = completedTaskRuns
        event.priority = priority
        event.extraInfo = extraInfo
        
        return event
        
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
    
    
    override open static func primaryKey() -> String? {
        return "identifier"
    }
    
    override open static func indexedProperties() -> [String] {
        return ["eventType"]
    }
    
    @objc dynamic public var identifier: String = ""
    
    @objc dynamic public var eventType: String = ""
    
    @objc dynamic public var startTime: Date = Date.distantPast
    
    public var duration: TimeInterval? {
        get {
            return self._duration != Double.infinity ? self._duration : nil
        }
        set(newDuration) {
            if let duration = newDuration {
                self._duration = duration
            }
            else {
                self._duration = Double.infinity
            }
        }
    }
    
    @objc dynamic var _duration: Double = Double.infinity
    
    @objc dynamic public var completed: Bool = false
    
    @objc dynamic public var completionTime: Date? = nil
    
    @objc dynamic public var priority: Int = 0
    
    public var completedTaskRuns: [String]? {
        get {
            if let completedTaskRuns = self._completedTaskRuns {
                return completedTaskRuns
            }
            else if self._completedTaskRunsSet {
                let completedTaskRuns = Array(self._completedTaskRunsList)
                self._completedTaskRuns = completedTaskRuns
                return completedTaskRuns
            }
            else {
                return nil
            }
        }
        set(newCompletedTaskRuns) {
            self._completedTaskRunsList.removeAll()
            if let completedTaskRuns = newCompletedTaskRuns {
                self._completedTaskRunsSet = true
                self._completedTaskRuns = completedTaskRuns
                self._completedTaskRunsList.append(objectsIn: completedTaskRuns)
            }
            else {
                self._completedTaskRunsSet = false
                self._completedTaskRuns = []
            }
        }
    }
    
    private var _completedTaskRuns: [String]?
    
    @objc dynamic public var _completedTaskRunsSet: Bool = false
    var _completedTaskRunsList: List<String> = List()
    
    @objc dynamic var extraInfoJSONString: String? = nil
    var _extraInfo: JSON? = nil
    public var extraInfo: JSON? {
        get {
            if let extraInfo = self._extraInfo {
                return extraInfo
            }
            else if let extraInfoString = self.extraInfoJSONString,
                let extraInfo = self.jsonForString(extraInfoString) {
                self._extraInfo = extraInfo
                return extraInfo
            }
            else {
                return nil
            }
        }
        set(newExtraInfo) {
            self._extraInfo = extraInfo
            if let extraInfo = newExtraInfo {
                self.extraInfoJSONString = self.stringForJSON(extraInfo)
            }
            else {
                self.extraInfoJSONString = nil
            }
        }
    }
    
    private func jsonForString(_ string: String) -> JSON? {
        do {
            guard let jsonData = string.data(using: .utf8),
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON else {
                    return nil
            }
            
            return json
            
            
        }
        catch let error {
            //Do a better job of handling this here!!
            assertionFailure("Cannot convert datapoint")
            //            debugPrint(error)
            return nil
        }
        
    }
    
    private func stringForJSON(_ json: JSON) -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            guard let string = String(data: data, encoding: .utf8) else {
                return nil
            }
            return string
        }
            
        catch let error {
            //Do a better job of handling this here!!
            assertionFailure("Cannot convert extra info")
            return nil
            //            debugPrint(error)
        }
    }

}
