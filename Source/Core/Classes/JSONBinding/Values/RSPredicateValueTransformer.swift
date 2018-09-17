//
//  RSPredicateValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 9/14/18.
//

import UIKit
import Gloss

class RSPredicateValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "predicate" == type
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        
        guard let predicate: RSPredicate = "predicate" <~~ jsonObject else {
            return nil
        }
        
        let predicateValue = RSPredicateManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
        return RSValueConvertible(value: predicateValue as AnyObject)
        
    }

}
