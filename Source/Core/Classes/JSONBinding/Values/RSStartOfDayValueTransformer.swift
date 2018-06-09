//
//  RSStartOfDayValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/8/18.
//

import UIKit
import Gloss

open class RSStartOfDayValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "startOfDay"
    }
    
    //takes date parameter and returns the start of the day for that date
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {

        
        guard let dateJSON: JSON = "date" <~~ jsonObject,
            let date: Date = RSValueManager.processValue(jsonObject: dateJSON, state: state, context: context)?.evaluate() as? Date else {
                return nil
        }
        
        return RSValueConvertible(value: Calendar.current.startOfDay(for: date) as NSDate)
        
    }
    
}
