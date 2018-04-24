//
//  RSStateValue.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import CoreLocation

public class RSStateValue: Glossy {
    
    public func toJSON() -> JSON? {
        return self.json
    }
    
    
    public let identifier: String
    public let type: String
    public let defaultValue: AnyObject?
    public let stateManager: String
    
    public let json: JSON
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let type: String = "type" <~~ json,
            let stateManager: String  = "stateManager" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        self.defaultValue = "default" <~~ json
        self.stateManager = stateManager
        
        self.json = json
    
    }
    
    static public func defaultValue(type: String, value: AnyObject?) -> ValueConvertible? {
        
        switch type {
        case "Date":
            return RSValueConvertible(value: NSNull())
            
        case "StringArray":
            guard let value = value as? [String] else {
                return nil
            }
            
            return RSValueConvertible(value: value as NSArray)
            
        case "IntArray":
            guard let value = value as? [Int] else {
                return nil
            }
            
            return RSValueConvertible(value: value as NSArray)
            
        case "JSONArray":
            guard let value = value as? [JSON] else {
                return nil
            }
            
            return RSValueConvertible(value: value as NSArray)
            
        case "GeofenceRegion":
            return nil
            
        case "GeofenceRegionArray":
            return nil
            
        case "Location":
            return nil
            
        case "TimeOfDay":
            //"P1DT13H24M18S"
            guard let isoString = value as? String,
                let dateComponents = DateComponents(ISO8601String: isoString) else {
                    return nil
            }
            return RSValueConvertible(value: dateComponents as NSDateComponents)
            
        case "DateComponents":
            //"P1DT13H24M18S"
            guard let isoString = value as? String,
                let dateComponents = DateComponents(ISO8601String: isoString) else {
                    return nil
            }
            return RSValueConvertible(value: dateComponents as NSDateComponents)
            
        case "TimeInterval":
            if let timeInterval = value as? TimeInterval {
                return RSValueConvertible(value: timeInterval as NSNumber)
            }
            else if  let isoString = value as? String,
                let timeInterval = TimeInterval(ISO8601String: isoString) {
                return RSValueConvertible(value: timeInterval as NSNumber)
            }
            else {
                return nil
            }
            
        case "UUID":
            return RSValueConvertible(value: NSNull())
            
        case "Boolean":
            guard let value = value as? Bool else {
                return nil
            }
            
            return RSValueConvertible(value: value as NSNumber)
            
        default:
            return RSValueConvertible(value: value)
        }
    
    }
    
    func getDefaultValue() -> ValueConvertible? {
        return RSStateValue.defaultValue(type: self.type, value: self.defaultValue)
    }
    
//    static func typeMatches(type: String, object: NSObject) -> Bool {
    static func typeMatches(type: String, object: AnyObject?) -> Bool {
        
        //TODO: should nil objects always match?
        //TODO: This is not working
        if object == nil || object is NSNull {
            return true
        }
        
        switch type {
            
        case "Date":
            return (object as? Date) != nil
            
        case "StringArray":
            return (object as? [String]) != nil
            
        case "JSONArray":
            return (object as? [JSON]) != nil
            
        case "IntArray":
            return (object as? [Int]) != nil
            
        case "GeofenceRegion":
            return (object as? CLCircularRegion) != nil
            
        case "GeofenceRegionArray":
            return (object as? [CLCircularRegion]) != nil
            
        case "Location":
            return (object as? CLLocation) != nil
            
        case "TimeOfDay":
            return (object as? DateComponents) != nil
            
        case "DateComponents":
            return (object as? DateComponents) != nil
            
        case "TimeInterval":
            return (object as? TimeInterval) != nil
            
        case "Boolean":
            return (object as? Bool) != nil
            
        case "Integer":
            return (object as? Int) != nil
            
        case "UUID":
            return (object as? UUID) != nil
            
        case "String":
            return (object as? String) != nil
            
        case "Double":
            return (object as? Double) != nil
            
        default:
            return false
        }
        
        
    }
    
    
    

}
