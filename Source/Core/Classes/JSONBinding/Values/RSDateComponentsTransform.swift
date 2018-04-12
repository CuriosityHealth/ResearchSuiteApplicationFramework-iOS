//
//  RSDateComponentsTransform.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/24/17.
//

import UIKit
import Gloss

///this should be able to take a list of things that evaluate to date components and merge them
open class RSDateComponentsTransform: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return type == "dateComponents"
    }
    
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String : AnyObject]) -> ValueConvertible? {
        
        //we have a list of values that should evaluate to either date or date components
        guard let objectsToMerge: [JSON] = "merge" <~~ jsonObject else {
                return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        
        let finalDateComponentsOpt: DateComponents? = objectsToMerge.reduce(nil) { (acc, json) -> DateComponents? in
            
            guard let componentsStringArray: [String] = "components" <~~ json else {
                return acc
            }
            
            let components = Set(componentsStringArray.compactMap { calendar.component(fromComponentString: $0) })
            
            //this isn't going to evaluate directly into a date, we need to use valuemanager to handle this
            if let dateJSON: JSON = "date" <~~ json,
                let dateConvertible = RSValueManager.processValue(jsonObject: dateJSON, state: state, context: context),
                let date = dateConvertible.evaluate() as? Date {
                return calendar.dateComponents(components, mergeFrom: date, mergeInto: acc ?? DateComponents())
            }
            else if let dateComponentsJSON: JSON = "dateComponents" <~~ json,
                let dateComponentsConvertible = RSValueManager.processValue(jsonObject: dateComponentsJSON, state: state, context: context),
                let dateComponents = dateComponentsConvertible.evaluate() as? DateComponents {
                return calendar.dateComponents(components, mergeFrom: dateComponents, mergeInto: acc ?? DateComponents())
            }
            else {
                return acc
            }
            
        }
        
        if let finalDateComponents = finalDateComponentsOpt {
            return RSValueConvertible(value: finalDateComponents as NSDateComponents)
        }
        else {
            return nil
        }
        
    }
    

}
