//
//  RSSetValueInStateActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/25/17.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import Gloss
import ReSwift

open class RSSetValueInStateActionTransformer: RSActionTransformer {
    
    open static func supportsType(type: String) -> Bool {
        return "setValueInState" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
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
