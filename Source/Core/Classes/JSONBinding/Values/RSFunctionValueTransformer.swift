//
//  RSFunctionValueTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/28/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSFunctionValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "function" == type
    }
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        guard let identifier: String = "identifier" <~~ jsonObject,
            let functionValue = RSStateSelectors.getFunctionValue(state, for: identifier) else {
                return nil
        }
        
        return functionValue.generateValueConvertible(state: state)
    }
    
}
