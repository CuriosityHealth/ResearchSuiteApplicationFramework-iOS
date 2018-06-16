//
//  RSExpressionValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/15/18.
//

import UIKit
import Gloss

open class RSExpressionValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "expression"
    }
    
    //takes a string, converts it into an NSExpression, and evaluates it
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        guard let expressionJSON: JSON = "expression" <~~ jsonObject,
            let expressionString: String = RSValueManager.processValue(jsonObject: expressionJSON, state: state, context: context)?.evaluate() as? String else {
                return nil
        }
        
        let expression = NSExpression(format: expressionString)
        
        return RSValueConvertible(value: expression.expressionValue(with: nil, context: nil) as AnyObject)
    }

}
