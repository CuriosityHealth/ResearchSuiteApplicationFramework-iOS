//
//  RSJSONSelectorValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 8/23/18.
//

import UIKit
import Gloss

open class RSSelectorValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "selector"
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        guard let valueJSON: JSON = "value" <~~ jsonObject,
            let value: AnyObject = RSValueManager.processValue(jsonObject: valueJSON, state: state, context: context)?.evaluate(),
            let pathJSON: JSON = "path" <~~ jsonObject,
            let path: String = RSValueManager.processValue(jsonObject: pathJSON, state: state, context: context)?.evaluate() as? String else {
            return nil
        }
        
        let pathComponentStrings: [String] = path.split(separator: ".").map { String($0) } as [String]
        let pathComponents: [AnyObject] = pathComponentStrings.map { componentString in
            
            if let componentInt = Int(componentString) {
                return componentInt as AnyObject
            }
            else {
                return componentString as AnyObject
            }
        }
        
        if let selectedValue = RSSelectorResult.recursivelyExtractValue(path: pathComponents, collection: value) {
            return RSValueConvertible(value: selectedValue)
        }
        else {
            return nil
        }
        
    }
    
}
