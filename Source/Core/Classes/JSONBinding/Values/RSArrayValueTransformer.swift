//
//  RSArrayValueTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//

import UIKit
import Gloss

open class RSArrayValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "array"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        guard let entries:[JSON] = "entries" <~~ jsonObject else {
            return nil
        }
        
        let array: [AnyObject] = entries.flatMap { RSValueManager.processValue(jsonObject: $0, state: state, context: [:])?.evaluate() }
        return RSValueConvertible(value: array as NSArray)
    }

}
