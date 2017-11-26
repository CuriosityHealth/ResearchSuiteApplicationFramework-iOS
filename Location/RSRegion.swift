//
//  RSRegion.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/26/17.
//

import UIKit
import Gloss

open class RSRegion: Gloss.Decodable {
    
    public let identifier: String
    public let location: JSON
    public let radius: JSON
    public let predicate: RSPredicate?
    public let handlerActions: [JSON]?
    public let json: JSON
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let location: JSON = "location" <~~ json,
            let radius: JSON = "radius" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.location = location
        self.radius = radius
        self.predicate = "predicate" <~~ json
        self.handlerActions = "handlerActions" <~~ json
        self.json = json
        
    }

}
