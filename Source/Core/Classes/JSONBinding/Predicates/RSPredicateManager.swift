//
//  RSPredicateManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/16/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSPredicateManager: NSObject {
    
    public static func generatePredicate(predicate: RSPredicate, state: RSState, context: [String: AnyObject]) -> NSPredicate? {
        let nsPredicate = NSPredicate.init(format: predicate.format)
        
        guard let substitutionsJSON = predicate.substitutions else {
            return nsPredicate
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
        
        guard substitutions.count == substitutionsJSON.count else {
            return nil
        }
        
        return nsPredicate.withSubstitutionVariables(substitutions)
    }
    
    public static func apply(predicate: RSPredicate, to array: [AnyObject], state: RSState, context: [String: AnyObject]) -> [AnyObject] {
        
        guard let predicate = self.generatePredicate(predicate: predicate, state: state, context: context) else {
            return []
        }
        
        
        
        debugPrint(array)
        
        array.forEach { (element) in
            debugPrint(element)
        }
        
        
        let arrayToApplyTo = array as NSArray
        return arrayToApplyTo.filtered(using: predicate) as [AnyObject]
    }
    
    public static func evaluatePredicate(predicate: RSPredicate, state: RSState, context: [String: AnyObject]) -> Bool {
        //construct substitution dictionary
        
        guard let predicate = self.generatePredicate(predicate: predicate, state: state, context: context) else {
                return false
        }
        
        return predicate.evaluate(with: nil)
        
    }

}
