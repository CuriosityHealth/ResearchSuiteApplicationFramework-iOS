//
//  RSResetStateManagerActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/21/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ReSwift

open class RSResetStateManagerActionTransformer: RSActionTransformer {
    public static func supportsType(type: String) -> Bool {
        return "resetStateManager" == type
    }
    //this return a closure, of which state and store are injected
    public static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let stateManagerID: String = "stateManagerID" <~~ jsonObject else {
                return nil
        }
        
        return { state, store in

            store.dispatch(RSActionCreators.resetStateManager(stateManagerID: stateManagerID))
            
            return nil
            
        }
    }
}
