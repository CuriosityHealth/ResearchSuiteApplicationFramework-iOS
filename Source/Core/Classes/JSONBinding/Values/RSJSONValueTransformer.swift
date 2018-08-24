//
//  RSJSONValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/20/18.
//

import UIKit
import Gloss

open class RSJSONValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "json"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        guard let json: [String: JSON] = "json" <~~ jsonObject else {
            return nil
        }
        
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
        
        let pairs: [(String, Any)] = json.compactMap { (pair) -> (String, Any)? in
            guard let value = RSValueManager.processValue(jsonObject: pair.value, state: state, context: fullContext)?.evaluate() else {
                return nil
            }
            
            return (pair.key, value)
        }
        
        assert(pairs.count == json.keys.count)
        
        let map = Dictionary.init(uniqueKeysWithValues: pairs)
        return RSValueConvertible(value: map as AnyObject)
    }
    
}
