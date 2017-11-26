//
//  RSLocationConfiguration.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//

import UIKit
import Gloss

open class RSLocationConfiguration: Gloss.Decodable {
    
    //location config
    //by default, we do not monitor location changes
    //TODO: Add support for significant location changes
    //TODO: Add support for regular location changes
    //We do provide an action to request the current location
    //The config should provide a list of actions to execute when a new location is processed
    //RSSensedLocationValueTransform should support this
    public let predicate: RSPredicate?
    public let onUpdateActions: RSActivity.OnCompletionStruct?
    
    public required init?(json: JSON) {
        
        guard let onUpdate: JSON = "onUpdateActions" <~~ json,
            let onSuccess: [JSON] = "onSuccess" <~~ onUpdate,
            let onFailure: [JSON] = "onFailure" <~~ onUpdate,
            let finally: [JSON] = "finally" <~~ onUpdate else {
            return nil
        }
        
        self.predicate = "predicate" <~~ json
        self.onUpdateActions = RSActivity.OnCompletionStruct(onSuccessActions: onSuccess, onFailureActions: onFailure, finallyActions: finally)
    }

}
