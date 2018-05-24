//
//  RSTemplatedStringValueTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 5/6/18.
//

import UIKit
import Mustache
import Gloss

open class RSTemplatedStringValueTransformer: RSValueTransformer {
    
    public func registerFormatters(template: Template) {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        
        template.register(percentFormatter,  forKey: "percent")
    }
    
    public static func supportsType(type: String) -> Bool {
        return "templatedString" == type
    }
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        guard let template: String = "template" <~~ jsonObject,
            let substitutionsJSON: [String: JSON] = "substitutions" <~~ jsonObject else {
            return nil
        }
        
        var substitutions: [String: Any] = [:]
        
        substitutionsJSON.forEach({ (key: String, value: JSON) in
            
            if let valueConvertible = RSValueManager.processValue(jsonObject:value, state: state, context: context) {
                
                //so we know this is a valid value convertible (i.e., it's been recognized by the state map)
                //we also want to potentially have a null value substituted
                if let value = valueConvertible.evaluate() {
                    substitutions[key] = value
                }
                else {
                    //                    assertionFailure("Added NSNull support for this type")
                    let nilObject: AnyObject? = nil as AnyObject?
                    substitutions[key] = nilObject as Any
                }
                
            }
            
        })
        
        
        
        do {
            
            let template = try Template(string: template)
            let renderedString = try template.render(substitutions)
            
            return RSValueConvertible(value: renderedString as NSString)
        }
        catch let error {
            debugPrint(error)
            return nil
        }
        
    }

}
