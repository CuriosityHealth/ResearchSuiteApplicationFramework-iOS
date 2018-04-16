//
//  RSQueueActivityActionTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/26/17.
//
//

import UIKit
import ReSwift
import Gloss

open class RSQueueActivityActionTransformer: RSActionTransformer {
    
    open static func supportsType(type: String) -> Bool {
        return "queueActivity" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let activityID: String = "activityID" <~~ jsonObject else {
                return nil
        }
        
        return { state, store in
            
            store.dispatch(RSActionCreators.queueActivity(activityID: activityID))
            
            return nil
            
        }
    }

}
