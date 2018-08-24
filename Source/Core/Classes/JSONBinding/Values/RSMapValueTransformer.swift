//
//  RSMapValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 8/23/18.
//

import UIKit
import Gloss

class RSMapValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "map"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {

        let fullContext: [String: AnyObject] = {
            if let extraContextJSON: JSON = "extraContext" <~~ jsonObject,
                let extraContext: [String: Any] = RSValueManager.processValue(jsonObject: extraContextJSON, state: state, context: context)?.evaluate() as? [String: Any] {
                return context.merging(extraContext as [String: AnyObject], uniquingKeysWith: { (obj1, obj2) -> AnyObject in
                    return obj2
                })
            }
            else {
                return context
            }
        }()
        
        guard let entriesJSON: JSON = "entries" <~~ jsonObject else {
                return nil
        }
        
        let abstractEntries = RSValueManager.processValue(jsonObject: entriesJSON, state: state, context: fullContext)?.evaluate()
        let entriesOpt: [AnyObject]? = {
            if let array = abstractEntries as? [AnyObject] {
                return array
            }
            else if let dict = abstractEntries as? [String: Any] {
                return dict.map { ["key": $0.key, "value": $0.value] as AnyObject }
            }
            else {
                return nil
            }
        }()
        
        guard let entries = entriesOpt,
            let keyJSON: JSON = "key" <~~ jsonObject,
            let valueJSON: JSON = "value" <~~ jsonObject else {
                return nil
        }
        
        let transformFunction: (AnyObject) -> (String, AnyObject)? = { element in
            
            let extraContext: [String: AnyObject] = ["element": element]
            let fullContext = fullContext.merging(extraContext, uniquingKeysWith: { (obj1, obj2) -> AnyObject in
                return obj2
            })
            
            guard let key = RSValueManager.processValue(jsonObject: keyJSON, state: state, context: fullContext)?.evaluate() as? String,
                let value = RSValueManager.processValue(jsonObject: valueJSON, state: state, context: fullContext)?.evaluate() else {
                    return nil
            }
            
            return (key, value)
        }
        
        let entryPairs: [(String, AnyObject)] = entries.compactMap(transformFunction)
        return RSValueConvertible(value: Dictionary.init(uniqueKeysWithValues: entryPairs) as AnyObject)
    }

}
