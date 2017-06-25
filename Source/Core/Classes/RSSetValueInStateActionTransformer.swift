//
//  RSSetValueInStateActionTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/25/17.
//
//

import UIKit
import Gloss
import ReSwift
import ResearchSuiteResultsProcessor

open class RSSetValueInStateActionTransformer: RSActionTransformer {
    
    open static func supportsType(type: String) -> Bool {
        return "setValueInState" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject]) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let valueJSON: JSON = "value" <~~ jsonObject,
            let identifier: String = "identifier" <~~ jsonObject else {
            return nil
        }
        
        return { state, store in
            
            guard let valueConvertible = RSValueManager.evaluate(jsonObject:valueJSON, state: state, context: context) as? ValueConvertible,
                let value = valueConvertible.evaluate() as? NSObject else {
                return nil
            }
            
            store.dispatch(RSActionCreators.setValueInState(key: identifier, value: value))
            
            return nil
            
        }
    }
    
}
