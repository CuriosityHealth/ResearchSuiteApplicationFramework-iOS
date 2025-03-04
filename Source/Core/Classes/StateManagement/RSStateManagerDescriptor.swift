//
//  RSStateManagerDescriptor.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/21/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSStateManagerDescriptor: Gloss.JSONDecodable {
    
    let identifier: String
    let type: String
    let json: JSON
    
    public required init?(json: JSON) {
        guard let identifier: String = "identifier" <~~ json,
            let type: String = "type" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        self.json = json
        
    }

}
