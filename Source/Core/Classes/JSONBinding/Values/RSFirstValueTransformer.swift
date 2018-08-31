//
//  RSFirstValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 8/28/18.
//

import UIKit
import Gloss

open class RSFirstValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "first"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        guard let valuesJSON: [JSON] = "values" <~~ jsonObject else {
                return nil
        }
        
        return valuesJSON.reduce(nil, { (acc, valueJSON) -> ValueConvertible? in
            
            if acc != nil {
                return acc
            }
            
            if let value = RSValueManager.processValue(jsonObject: valueJSON, state: state, context: context)?.evaluate() {
                return RSValueConvertible(value: value)
            }
            else {
                return nil
            }
            
        })
        
    }
    
}
