//
//  RSPathTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/19/18.
//

import UIKit
import Gloss

open class RSPathTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "path" == type
    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        
        guard let value: String = "value" <~~ jsonObject else {
            return nil
        }
        
        if value == "parent",
            let layoutVC = context["layoutViewController"] as? RSLayoutViewController {
            let parentPath = layoutVC.parentLayoutViewController.matchedRoute.match.path
            return RSValueConvertible(value: parentPath as NSString)
        }
        else if value == "back",
            let previousPath = RSStateSelectors.pathHistory(state).dropLast().last {
            
            return RSValueConvertible(value: previousPath as NSString)
            
        }
        else {
            return nil
        }
    }
    
}
