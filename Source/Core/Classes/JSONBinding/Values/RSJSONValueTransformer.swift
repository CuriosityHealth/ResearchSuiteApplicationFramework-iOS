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
        
        let pairs: [(String, Any)] = json.compactMap { (pair) -> (String, Any)? in
            guard let value = RSValueManager.processValue(jsonObject: pair.value, state: state, context: context)?.evaluate() else {
                return nil
            }
            
            return (pair.key, value)
        }
        
        assert(pairs.count == json.keys.count)
        
        let map = Dictionary.init(uniqueKeysWithValues: pairs)
        return RSValueConvertible(value: map as AnyObject)
    }
    
}
