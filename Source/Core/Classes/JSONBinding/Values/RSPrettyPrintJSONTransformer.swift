//
//  RSPrettyPrintJSONTransformer.swift
//  Pods
//
//  Created by James Kizer on 5/19/18.
//

import UIKit
import Gloss

open class RSPrettyPrintJSONTransformer: RSValueTransformer {

    public static func supportsType(type: String) -> Bool {
        return "prettyPrint" == type
    }
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        guard let value: JSON = "value" <~~ jsonObject,
            let valueConvertible = RSValueManager.processValue(jsonObject:value, state: state, context: context),
            let jsonValue = valueConvertible.evaluate() as? JSON,
            JSONSerialization.isValidJSONObject(jsonValue),
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonValue, options: [.prettyPrinted]),
            let jsonString = String(data: jsonData, encoding: .utf8) else {
                return nil
        }
        
        return RSValueConvertible(value: jsonString as AnyObject)
    }
    
}
