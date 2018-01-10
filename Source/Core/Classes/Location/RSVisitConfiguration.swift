//
//  RSVisitConfiguration.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//

import UIKit
import Gloss

open class RSVisitConfiguration: Gloss.Decodable {
    
    //visit config
    //by default, we do not monitor visits
    public let predicate: RSPredicate?
    public let onUpdate: RSPromise
    
    public required init?(json: JSON) {
        
        guard let onUpdate: RSPromise = "onUpdate" <~~ json else {
            return nil
        }
        
        self.predicate = "predicate" <~~ json
        self.onUpdate = onUpdate
    }
    
}
