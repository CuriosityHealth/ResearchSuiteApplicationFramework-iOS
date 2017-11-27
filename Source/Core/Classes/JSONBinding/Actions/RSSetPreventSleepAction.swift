//
//  RSSetPreventSleepAction.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//

import UIKit
import Gloss
import ReSwift

open class RSSetPreventSleepAction: RSActionTransformer {
    
    open static func supportsType(type: String) -> Bool {
        return "setPreventSleep" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject]) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let valueJSON: JSON = "value" <~~ jsonObject else {
            return nil
        }
        
        return { state, store in
            
            guard let preventSleep = RSValueManager.processValue(jsonObject:valueJSON, state: state, context: context)?.evaluate() as? Bool else {
                return nil
            }
            
            store.dispatch(RSActionCreators.setPreventSleep(preventSleep: preventSleep))
            
            return nil
        }
    }
    
}
