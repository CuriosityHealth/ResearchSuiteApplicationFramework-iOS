//
//  RSSpecialValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 7/5/17.
//
//

import UIKit
import Gloss

open class RSSpecialValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "special" == type
    }
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        guard let identifier: String = "identifier" <~~ jsonObject else {
                return nil
        }
        
        return RSSpecialValueTransformer.value(for: identifier)
    }
    
    
    //TODO: Make this not hacky
    public static func value(for specialIdentifier: String) -> ValueConvertible? {
        
        switch specialIdentifier {
        case "now":
            return RSValueConvertible(value: Date() as AnyObject)
        case "UUID":
            return RSValueConvertible(value: UUID() as AnyObject)
        default:
            return nil
        }
    
    }

}
