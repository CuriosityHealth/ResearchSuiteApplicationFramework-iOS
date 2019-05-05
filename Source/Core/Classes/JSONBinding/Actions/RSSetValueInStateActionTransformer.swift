//
//  RSSetValueInStateActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/25/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ReSwift

open class RSSetValueInStateActionTransformer: RSActionTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "setValueInState" == type
    }
    //this return a closure, of which state and store are injected
    public static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        //TODO: at some point we want to add in a new type of setValueInState where multiple values can be updated atomicly
        guard let valueJSON: JSON = "value" <~~ jsonObject,
            let identifier: String = "identifier" <~~ jsonObject else {
            return nil
        }
        
        return { state, store in
            
            //TODO: Support NSNull
            //Maybe, split this guard, if valueConvertible return nil, then we can return nil
            //otherwise if evaulate returns nil, assume that we actually want to set the value in the state to nil
            guard let valueConvertible = RSValueManager.processValue(jsonObject:valueJSON, state: state, context: context) else {
                return nil
            }
            
            if let value = valueConvertible.evaluate() as? NSObject {
                store.dispatch(RSActionCreators.setValueInState(key: identifier, value: value))
            }
            else {
                store.dispatch(RSActionCreators.setValueInState(key: identifier, value: nil))
            }

            return nil
            
        }
    }
    
}
