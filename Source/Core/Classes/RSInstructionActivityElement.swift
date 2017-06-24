//
//  RSInstructionActivityElement.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ResearchKit
import Gloss
import ResearchSuiteTaskBuilder

public class RSInstructionActivityElement: RSActivityElement {
    
    let json: JSON
    
    required public init?(json: JSON) {
        
        self.json = json
        super.init(json: json)
        
    }
    
    open override func generateSteps(taskBuilder: RSTBTaskBuilder) -> [ORKStep]? {
        return taskBuilder.steps(forElement: self.json as JsonElement)
    }

}
