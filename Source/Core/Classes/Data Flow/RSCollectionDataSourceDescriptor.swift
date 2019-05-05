//
//  RSCollectionDataSourceDescriptor.swift
//  Pods
//
//  Created by James Kizer on 5/28/18.
//

import UIKit
import Gloss

open class RSCollectionDataSourceDescriptor {

    public let identifier: String
    public let type: String
    public let json: JSON
    
    required public init?(json: JSON) {
        guard let identifier: String = "identifier" <~~ json,
            let type: String = "type" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        self.json = json
    }
    
}
