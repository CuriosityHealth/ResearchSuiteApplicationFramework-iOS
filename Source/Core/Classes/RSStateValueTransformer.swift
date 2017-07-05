//
//  RSStateValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 7/5/17.
//
//

import UIKit
import Gloss

open class RSStateValueTransformer: RSValueTransformer {

    public static func supportsType(type: String) -> Bool {
        return "state" == type
    }
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        guard let identifier: String = "identifier" <~~ jsonObject else {
                return nil
        }
        
        return RSStateSelectors.getValueInStorage(state)(identifier)
    }
    
}
