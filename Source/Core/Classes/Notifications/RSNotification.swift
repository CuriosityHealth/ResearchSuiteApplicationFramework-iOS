//
//  RSNotification.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSNotification: Gloss.JSONDecodable {
    
    public let identifier: String
    public let type: String
    public let predicate: RSPredicate?
    public let handlerActions: [JSON]?
    public let json: JSON
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let type: String = "type" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        self.predicate = "predicate" <~~ json
        self.handlerActions = "handlerActions" <~~ json
        self.json = json
        
    }
    
    public init(identifier: String, type: String, predicate: RSPredicate?, handlerActions: [JSON]?, json: JSON) {
        self.identifier = identifier
        self.type = type
        self.predicate = predicate
        self.handlerActions = handlerActions
        self.json = json
    }

}
