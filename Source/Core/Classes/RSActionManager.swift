//
//  RSActionManager.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import Gloss
import ReSwift

open class RSActionManager: NSObject {
    
    open class func processAction(action: JSON, context: [String: AnyObject], store: Store<RSState>) {
        
        //check for predicate and evaluate
        //if predicate exists and evaluates false, do not execute action
        if let predicate: RSPredicate = "predicate" <~~ action,
            RSActivityManager.evaluatePredicate(predicate: predicate, state: store.state, context: context) == false {
            return
        }
        
        //if action malformed, do not execute action
        guard let type: String = "type" <~~ action else {
            return
        }
        
        debugPrint(action)

        //TODO: I don't really like this, maybe create an action manager object?
        let transforms = RSApplicationDelegate.appDelegate.actionCreatorTransforms
        
        for transformer in transforms {
            if transformer.supportsType(type: type) {
                guard let actionClosure = transformer.generateAction(jsonObject: action, context: context) else {
                    return
                }
                
                store.dispatch(actionClosure)
            }
        }
    
    }
    
    open class func processActions(actions: [JSON], context: [String: AnyObject], store: Store<RSState>) {
        actions.forEach { RSActionManager.processAction(action: $0, context: context, store: store) }
    }

}
