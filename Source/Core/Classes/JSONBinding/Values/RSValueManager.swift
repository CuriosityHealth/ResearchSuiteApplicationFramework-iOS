//
//  RSValueManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/25/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import Gloss

open class RSValueManager: NSObject {
    
    //TODO: add state value transformer
//    public static let valueTransformers: [RSValueTransformer.Type] = [
//        RSResultTransformValueTransformer.self,
//        RSConstantValueTransformer.self,
//        RSFunctionValueTransformer.self,
//        RSStepTreeResultTransformValueTransformer.self,
//        RSStateValueTransformer.self,
//        RSSpecialValueTransformer.self,
//        RSLiteralValueTransformer.self,
//        RSDateComponentsTransform.self
//    ]
    
    //generate values
    //TODO: make distinction between truly nil values and programming / config errors
    //right now, we just return nil, which is ambiguous
    public static func processValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        
        guard let type: String = "type" <~~ jsonObject else {
            return nil
        }
        
        let transforms = RSApplicationDelegate.appDelegate.valueTransforms
        
        for transformer in transforms {
            if transformer.supportsType(type: type),
                let value = transformer.generateValue(jsonObject: jsonObject, state: state, context: context) {
                
                return value
                
            }
        }
        
        return nil
        
    }
    
    public static func valueChanged(jsonObject: JSON, state: RSState, lastState: RSState, context: [String: AnyObject]) -> Bool {
        guard let currentValueConvertible = RSValueManager.processValue(jsonObject: jsonObject, state: state, context: context),
            let lastValueConvertible = RSValueManager.processValue(jsonObject: jsonObject, state: lastState, context: [:]) else {
                return false
        }
        
        let currentValue = currentValueConvertible.evaluate()
        let lastValue = lastValueConvertible.evaluate()
        
        if currentValue == nil && lastValue == nil {
            return false
        }
        
        //we checked above to see if both are nil,
        //therefore if one is, the other isnt
        if currentValue == nil || lastValue == nil {
            return true
        }
        
        guard let c = currentValue as? NSObject,
            let l = lastValue as? NSObject else {
                assertionFailure("Assuming that all objects inherit from NSObject")
                return false
        }
        
        //otherwise, we know that both are not nil
        return c != l
    }

}
