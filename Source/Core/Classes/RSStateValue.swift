//
//  RSStateValue.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import Gloss
import CoreLocation

public class RSStateValue: Decodable {
    
    public let identifier: String
    public let type: String
    public let defaultValue: AnyObject?
    public let stateManager: String
    
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
    
    }
    
    func getDefaultValue() -> ValueConvertible? {
        switch type {
        case "Date":
            return RSValueConvertible(value: NSNull())
            
        case "StringArray":
            guard let value = self.defaultValue as? [String] else {
                return nil
            }
            
            return RSValueConvertible(value: value as NSArray)
            
        case "Location":
            return nil
            
        case "TimeOfDay":
            return nil
            
        case "UUID":
            return RSValueConvertible(value: NSNull())
            
        case "Boolean":
            guard let value = self.defaultValue as? Bool else {
                return nil
            }
            
            return RSValueConvertible(value: value as NSNumber)
            
        default:
            return nil
        }
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
            
        case "Location":
            return (object as? CLLocation) != nil
            
        case "TimeOfDay":
            return (object as? DateComponents) != nil
            
        case "Boolean":
            return (object as? Bool) != nil
            
        case "Integer":
            return (object as? Int) != nil
            
        case "UUID":
            return (object as? UUID) != nil
            
        case "String":
            return (object as? String) != nil
            
        default:
            return false
        }
        
        
    }
    
    
    

}
