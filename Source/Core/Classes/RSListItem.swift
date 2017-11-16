//
//  RSListItem.swift
//  Pods
//
//  Created by James Kizer on 7/4/17.
//
//

import UIKit
import Gloss

open class RSListItem: Gloss.Decodable {
    
    public let identifier: String
    public let predicate: RSPredicate?
    public let onTapActions: [JSON]
    public let element: JSON
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.predicate = "predicate" <~~ json
        self.onTapActions = "onTap" <~~ json ?? []
        self.element = json
    }

}
