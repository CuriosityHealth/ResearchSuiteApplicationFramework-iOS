//
//  RSRoute.swift
//  Pods
//
//  Created by James Kizer on 7/3/17.
//
//

import UIKit
import Gloss


open class RSRoute: Gloss.Decodable, Equatable {
    
    public let identifier: String
    public let layout: String
    public let predicate: RSPredicate?
    public let parent: String?
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let layout: String = "layout" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.layout = layout
        self.predicate = "predicate" <~~ json
        self.parent = "parent" <~~ json
    }
    
    public static func ==(lhs: RSRoute, rhs: RSRoute) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}
