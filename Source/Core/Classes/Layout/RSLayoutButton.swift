//
//  RSLayoutButton.swift
//  Pods
//
//  Created by James Kizer on 7/6/17.
//
//

import UIKit
import Gloss

open class RSLayoutButton: Gloss.JSONDecodable {
    
    public let identifier: String
    public let title: String
    public let predicate: RSPredicate?
    public let onTapActions: [JSON]
    public let element: JSON
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let title: String = "title" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.title = title
        self.predicate = "predicate" <~~ json
        self.onTapActions = "onTap" <~~ json ?? []
        self.element = json
    }

}
