//
//  RSValueManager.swift
//  Pods
//
//  Created by James Kizer on 6/25/17.
//
//

import UIKit
import ReSwift
import Gloss

open class RSValueManager: NSObject {
    
    public static let valueTransformers: [RSValueTransformer.Type] = [
        RSResultTransformValueTransformer.self
    ]
    
    //generate values
    public static func evaluate(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> AnyObject? {
        
        guard let type: String = "type" <~~ jsonObject else {
            return nil
        }
        
        for transformer in RSValueManager.valueTransformers {
            if transformer.supportsType(type: type),
                let value = transformer.generateValue(jsonObject: jsonObject, state: state, context: context) {
                
                return value
                
            }
        }
        
        return nil
        
    }

}
