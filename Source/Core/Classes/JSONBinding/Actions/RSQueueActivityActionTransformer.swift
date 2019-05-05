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
    
    public static func supportsType(type: String) -> Bool {
        return "queueActivity" == type
    }
    
    public static func generateExtraOnCompletionActions(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> RSOnCompletionActions? {
        
        guard let onCompletionJSON: JSON = "onCompletion" <~~ jsonObject else {
            return nil
        }
        
        let generateActions: (String) ->  [RSOnCompletionActionGenerator]? = { jsonKey in
            guard let actionsJSON: [JSON] = jsonKey <~~ onCompletionJSON else {
                return nil
            }
            
            let actions: [RSOnCompletionActionGenerator] = actionsJSON.map { actionJSON in
                let actionGenerator: RSOnCompletionActionGenerator = { context in
                    return { state, store in
                        actionManager.processAction(action: actionJSON, context: context, store: store)
                        return nil
                    }
                }
                
                return actionGenerator
            }
            
            return actions
        }

        return RSOnCompletionActions(
            onSuccessActions: generateActions("onSuccess"),
            onFailureActions: generateActions("onFailure"),
            finallyActions: generateActions("finally")
        )
    }
    
    //this return a closure, of which state and store are injected
    public static func generateAction(jsonObject: JSON, context: [String: AnyObject], actionManager: RSActionManager) -> ((_ state: RSState, _ store: Store<RSState>) -> Action?)? {
        
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
            
            let extraOnCompletionActions: RSOnCompletionActions? = self.generateExtraOnCompletionActions(jsonObject: jsonObject, context: context, actionManager: actionManager)
            
            store.dispatch(RSActionCreators.queueActivity(
                activityID: activityID,
                context: extraContext,
                extraOnCompletionActions: extraOnCompletionActions
            ))
            
            return nil
            
        }
    }
    
    public static func supportsURLType(type: String) -> Bool {
        return "queue_activity" == type
    }
    
    public static func convertURLToJSONAction(queryParams: [String : String], context: [String : AnyObject], store: Store<RSState>) -> JSON? {
        
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
