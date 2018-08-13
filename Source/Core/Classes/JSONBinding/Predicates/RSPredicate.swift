//
//  RSPredicate.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/26/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

public class RSPredicate: Glossy {
    
    let identifier: String?
    let format: String
    let substitutions: [String: JSON]?
    
    required public init?(json: JSON) {
        
        guard let format: String = "format" <~~ json else {
                return nil
        }
        
        self.identifier = "identifier" <~~ json
        self.format = format
        self.substitutions  = "substitutions" <~~ json
        
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "identifier" ~~> self.identifier,
            "format" ~~> self.format,
            "substitutions" ~~> self.substitutions
            ])
    }
    
    

}
