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
    public let protected: Bool
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let type: String = "type" <~~ json,
            let protected:Bool  = "protected" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        self.defaultValue = "default" <~~ json
        self.protected = protected
    
    }
    
    func getDefaultValue() -> ValueConvertible? {
        switch type {
        case "Date":
            return RSValueConvertible(value: nil)
            
        case "StringArray":
            guard let value = self.defaultValue as? [String] else {
                return nil
            }
            
            return RSValueConvertible(value: value as NSArray)
            
        case "Location":
            return nil
            
        case "TimeOfDay":
            return nil
            
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
        if object == nil {
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
            
        default:
            return false
        }
        
        
    }
    
    
    

}
