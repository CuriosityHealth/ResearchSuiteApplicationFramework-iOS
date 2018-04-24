//
//  RSArrayFilterValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 4/22/18.
//

import UIKit
import Gloss

open class RSArrayFilterValueTransformer: RSValueTransformer {
    public static func supportsType(type: String) -> Bool {
        return "arrayFilter" == type
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        guard let entries:[JSON] = "entries" <~~ jsonObject else {
            return nil
        }
        
        let array: [AnyObject] = entries.compactMap { RSValueManager.processValue(jsonObject: $0, state: state, context: [:])?.evaluate() }
        return RSValueConvertible(value: array as NSArray)
        
    }
    

}
