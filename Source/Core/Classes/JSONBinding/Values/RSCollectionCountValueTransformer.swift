//
//  RSCollectionCountValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 9/14/18.
//

import UIKit
import Gloss

class RSCollectionCountValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "collectionCount" == type
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        
        guard let collectionJSON: JSON = "collection" <~~ jsonObject,
            let collection = RSValueManager.processValue(jsonObject: collectionJSON, state: state, context: context)?.evaluate() else {
                return nil
        }
        
        if let collection = collection as? AnyCollection<Any> {
            return RSValueConvertible(value: collection.count as AnyObject)
        }
        
        if let array = collection as? NSArray {
            return RSValueConvertible(value: array.count as AnyObject)
        }
        else if let dict = collection as? NSDictionary {
            return RSValueConvertible(value: dict.count as AnyObject)
        }
        else {
            return nil
        }
    }

}
