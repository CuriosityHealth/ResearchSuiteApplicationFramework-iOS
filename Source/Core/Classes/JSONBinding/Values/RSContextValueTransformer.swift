//
//  RSContextValueTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 5/6/18.
//

import UIKit
import Gloss

open class RSContextValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "context" == type
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        
        if let keyPath: String = "keyPath" <~~ jsonObject {
            guard let value = context.valueForKeyPath(keyPath: keyPath) else {
                return nil
            }
            
            return RSValueConvertible(value: value as AnyObject)
        }
        else if let mapping: [String: String] = "mapping" <~~ jsonObject {
            
            var mappedValues: [String: Any] = [:]
            
            mapping.forEach { (pair) in
                guard let value = context.valueForKeyPath(keyPath: pair.value) else {
                    return
                }
                
                mappedValues[pair.key] = value
            }

            return RSValueConvertible(value: mappedValues as AnyObject)
        }
        else if let path: [AnyObject] = "path" <~~ jsonObject {
            guard let value = RSSelectorResult.recursivelyExtractValue(path: path, collection: context as AnyObject) else {
                return nil
            }
            
            return RSValueConvertible(value: value as AnyObject)
        }
        else {
            return nil
        }
    }

}
