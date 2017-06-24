//
//  RSActivityElement.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import Gloss
import ResearchKit
import ResearchSuiteTaskBuilder

open class RSActivityElement: Decodable {

    let identifier: String
    let type: String
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let type: String = "type" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        
    }
    
    open func generateSteps(taskBuilder: RSTBTaskBuilder) -> [ORKStep]? {
        return nil
    }
    
}
