//
//  RSMostRecentDateTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/8/18.
//

import UIKit
import Gloss

open class RSMostRecentDateTransformer: RSValueTransformer {

    public static func supportsType(type: String) -> Bool {
        return type == "mostRecentDate"
    }
    
    //this takes two parameters, a starting date and time interval. Returns the MOST RECENT date (past)
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        guard let anchorDateJSON: JSON = "anchorDate" <~~ jsonObject,
            let anchorDate: Date = RSValueManager.processValue(jsonObject: anchorDateJSON, state: state, context: context)?.evaluate() as? Date,
            let timeIntervalJSON: JSON = "timeInterval" <~~ jsonObject,
            let timeInterval: TimeInterval = RSValueManager.processValue(jsonObject: timeIntervalJSON, state: state, context: context)?.evaluate() as? TimeInterval else {
                return nil
        }
        
        var iteratedDate: Date = anchorDate
        let now = Date()
        
        //loop until newDate is in the future
        while true {
            
            let newDate = iteratedDate.addingTimeInterval(timeInterval)
            if newDate > now {
                return  RSValueConvertible(value: iteratedDate as NSDate)
            }
            else {
                iteratedDate = newDate
            }
            
        }
        
    }
    
}
