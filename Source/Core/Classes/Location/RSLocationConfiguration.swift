//
//  RSLocationConfiguration.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSLocationConfiguration: Gloss.JSONDecodable {
    
    //location config
    //by default, we do not monitor location changes
    //TODO: Add support for significant location changes
    //TODO: Add support for regular location changes
    //We do provide an action to request the current location
    //The config should provide a list of actions to execute when a new location is processed
    //RSSensedLocationValueTransform should support this
    public let predicate: RSPredicate
    public let onUpdate: RSPromise
    
    public required init?(json: JSON) {
        
        guard let onUpdate: RSPromise = "onUpdate" <~~ json,
            let predicate: RSPredicate = "predicate" <~~ json else {
            return nil
        }
        
        self.predicate = predicate
        self.onUpdate = onUpdate
    }

}
