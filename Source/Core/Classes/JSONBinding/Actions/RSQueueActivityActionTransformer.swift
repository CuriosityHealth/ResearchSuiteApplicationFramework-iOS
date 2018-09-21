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

        return { state, store in
            
            //the implication is that we'd like the context to be evaluated when the queue activity action is emitted
            //rather than when it get's pulled off of the queue
            //this will allow for context chaining
            let extraContext: [String: AnyObject] = {
                
                if let extraContextJSON: [String: JSON] = "context" <~~ jsonObject {
                    
                    let pairs: [(String, AnyObject)] = extraContextJSON.compactMap({ (pair) -> (String, AnyObject)? in
                        
                        guard let value = RSValueManager.processValue(jsonObject: pair.value, state: state, context: context)?.evaluate() else {
                                return nil
                        }
                        
                        return (pair.key, value)
                        
                    })
                    
                    return Dictionary.init(uniqueKeysWithValues: pairs)
                    
                }
                else {
                    return [:]
                }
                
            }()
            
            store.dispatch(RSActionCreators.queueActivity(
                activityID: activityID,
                context: extraContext,
                extraOnCompletionActions: nil
            ))
            
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
