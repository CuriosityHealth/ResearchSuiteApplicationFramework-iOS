//
//  RSLiteralValueTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/15/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSLiteralValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "literal" == type
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        return RSValueConvertible(value: "value" <~~ jsonObject)
    }

}
