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
