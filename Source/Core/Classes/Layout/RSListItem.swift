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
    public let type: String
    public let predicate: RSPredicate?
    public let element: JSON
    public let title: AnyObject
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let type: String = "type" <~~ json,
            let title: AnyObject = "title" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        self.title = title
        self.predicate = "predicate" <~~ json
        self.element = json
    }

}
