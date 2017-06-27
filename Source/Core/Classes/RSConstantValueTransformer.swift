//
//  RSConstantValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/26/17.
//
//

import UIKit
import Gloss

open class RSConstantValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "constant" == type
    }
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        guard let identifier: String = "identifier" <~~ jsonObject,
            let constantValue = RSStateSelectors.getConstantValue(state, for: identifier) else {
                return nil
        }
        
        return constantValue
    }

}
