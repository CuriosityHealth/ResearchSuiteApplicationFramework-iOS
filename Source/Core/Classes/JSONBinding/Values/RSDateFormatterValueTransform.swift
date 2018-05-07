//
//  RSDateFormatterValueTransform.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 5/7/18.
//

import UIKit
import Gloss

extension DateFormatter.Style {
    static func fromString(style: String) -> DateFormatter.Style {
        switch(style) {
        case "none":
            return DateFormatter.Style.none
        case "short":
            return DateFormatter.Style.short
        case "medium":
            return DateFormatter.Style.medium
        case "long":
            return DateFormatter.Style.long
        case "full":
            return DateFormatter.Style.full
        default:
            return DateFormatter.Style.none
        }
        
    }
}

open class RSDateFormatterValueTransform: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "dateFormatter" == type
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {

        if let dateJSON: JSON = "date" <~~ jsonObject,
            let date: NSDate = RSValueManager.processValue(jsonObject:dateJSON, state: state, context: context)?.evaluate() as? NSDate {
            
            if let iso8601: Bool = "iso8601" <~~ jsonObject,
                iso8601 == true {
                return RSValueConvertible(value: ISO8601DateFormatter().string(from: date as Date) as AnyObject)
            }
            
            //we've got a date and a format string, convert it to a string
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
        
            if let formatString: String = "format" <~~ jsonObject {
                dateFormatter.dateFormat = formatString
            }
            else {
                if let timeStyleString: String = "timeStyle" <~~ jsonObject {
                    dateFormatter.timeStyle = DateFormatter.Style.fromString(style: timeStyleString)
                }
                
                if let dateStyleString: String = "dateStyle" <~~ jsonObject {
                    dateFormatter.dateStyle = DateFormatter.Style.fromString(style: dateStyleString)
                }
            }
            
            return RSValueConvertible(value: dateFormatter.string(from: date as Date) as AnyObject)
        }
        else if let dateStringJSON: JSON = "dateString" <~~ jsonObject,
            let dateString: String = RSValueManager.processValue(jsonObject:dateStringJSON, state: state, context: context)?.evaluate() as? String {
            
            if let iso8601: Bool = "iso8601" <~~ jsonObject,
                iso8601 == true {
                return RSValueConvertible(value: (ISO8601DateFormatter().date(from: dateString) as Date?) as AnyObject?)
            }
            
            else if let formatString: String = "format" <~~ jsonObject {
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                
                dateFormatter.dateFormat = formatString
                return RSValueConvertible(value: (dateFormatter.date(from: dateString) as Date?) as AnyObject?)
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }

}
