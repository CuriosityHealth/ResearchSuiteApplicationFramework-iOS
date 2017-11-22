//
//  RSGroupActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/21/17.
//

import UIKit
import Gloss
import ReSwift

open class RSGroupActionTransformer: RSActionTransformer {

    open static func supportsType(type: String) -> Bool {
        return "actionGroup" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject]) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let actions: [JSON] = "actions" <~~ jsonObject else {
            return nil
        }
        
        return { state, store in
            RSActionManager.processActions(actions: actions, context: context, store: store)
            return nil
        }
    }
    
}
