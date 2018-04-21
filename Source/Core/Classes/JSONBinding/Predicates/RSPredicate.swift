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

public class RSPredicate: Gloss.JSONDecodable {
    
    let format: String
    let substitutions: [String: JSON]?
    
    required public init?(json: JSON) {
        
        guard let format: String = "format" <~~ json else {
                return nil
        }
        
        self.format = format
        self.substitutions  = "substitutions" <~~ json
        
    }

}
