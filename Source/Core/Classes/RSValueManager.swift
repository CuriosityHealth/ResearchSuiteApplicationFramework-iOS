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
    
    //TODO: add state value transformer
    public static let valueTransformers: [RSValueTransformer.Type] = [
        RSResultTransformValueTransformer.self,
        RSConstantValueTransformer.self,
        RSFunctionValueTransformer.self,
        RSStepTreeResultTransformValueTransformer.self,
        RSStateValueTransformer.self
    ]
    
    //generate values
    //TODO: make distinction between truly nil values and programming / config errors
    //right now, we just return nil, which is ambiguous
    public static func processValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        
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
