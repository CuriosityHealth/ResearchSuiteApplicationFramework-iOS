//
//  RSSignOutActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/13/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ReSwift

open class RSSignOutActionTransformer: RSActionTransformer {

    open static func supportsType(type: String) -> Bool {
        return "signOut" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {

        return { state, store in
            return RSActionCreators.signOut()
        }
    }
    
}
