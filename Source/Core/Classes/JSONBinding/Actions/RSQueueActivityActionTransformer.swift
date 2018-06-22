//
//  RSQueueActivityActionTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/26/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import Gloss

open class RSQueueActivityActionTransformer: RSActionTransformer, RSURLToJSONActionConverter {
    
    open static func supportsType(type: String) -> Bool {
        return "queueActivity" == type
    }
    //this return a closure, of which state and store are injected
    open static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
        guard let activityID: String = "activityID" <~~ jsonObject else {
                return nil
        }
        
        let context: JSON? = "context" <~~ jsonObject
        
        return { state, store in
            
            store.dispatch(RSActionCreators.queueActivity(activityID: activityID, context: context))
            
            return nil
            
        }
    }
    
    open static func supportsURLType(type: String) -> Bool {
        return "queue_activity" == type
    }
    
    open static func convertURLToJSONAction(queryParams: [String : String], context: [String : AnyObject], store: Store<RSState>) -> JSON? {
        
        guard let activityIdentifier: String = queryParams["activity_id"] else {
            return nil
        }
        
        return [
            "type": "queueActivity",
            "activityID": activityIdentifier
        ]
        
//        {
//        "type": "queueActivity",
//        "activityID": "initialSurvey"
//        }
        
    }

}
