//
//  RSResetStateManagerActionTransformer.swift
//  Pods
//
//  Created by James Kizer on 7/21/17.
//
//

import UIKit
import Gloss
import ReSwift

open class RSResetStateManagerActionTransformer: RSActionTransformer {
    open static func supportsType(type: String) -> Bool {
        return "resetStateManager" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let stateManagerID: String = "stateManagerID" <~~ jsonObject else {
                return nil
        }
        
        return { state, store in

            store.dispatch(RSActionCreators.resetStateManager(stateManagerID: stateManagerID))
            
            return nil
            
        }
    }
}
