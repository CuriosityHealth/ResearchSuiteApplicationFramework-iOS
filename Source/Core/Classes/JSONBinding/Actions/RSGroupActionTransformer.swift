//
//  RSGroupActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/21/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ReSwift

open class RSGroupActionTransformer: RSActionTransformer {

    public static func supportsType(type: String) -> Bool {
        return "actionGroup" == type
    }
    //this return a closure, of which state and store are injected
    public static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let actions: [JSON] = "actions" <~~ jsonObject else {
            return nil
        }
        
        return { state, store in
            actionManager.processActions(actions: actions, context: context, store: store)
            return nil
        }
    }
    
}
