//
//  RSStepTreeConditionalNavigationRule.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/30/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSStepTreeConditionalNavigationRule: Gloss.JSONDecodable {
    
    let predicate: RSPredicate
    let destination: String
    
    public required init?(json: JSON) {
        guard let predicate: RSPredicate = "predicate" <~~ json,
            let destination: String = "destination" <~~ json else {
                return nil
        }
        
        self.predicate = predicate
        self.destination = destination
    }

}
