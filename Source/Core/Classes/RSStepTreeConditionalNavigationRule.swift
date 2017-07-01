//
//  RSStepTreeConditionalNavigationRule.swift
//  Pods
//
//  Created by James Kizer on 6/30/17.
//
//

import UIKit
import Gloss

open class RSStepTreeConditionalNavigationRule: Decodable {
    
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
