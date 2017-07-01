//
//  RSElementListNodeDescriptor.swift
//  Pods
//
//  Created by James Kizer on 7/1/17.
//
//

import UIKit
import ResearchSuiteTaskBuilder
import Gloss

open class RSElementListNodeDescriptor: RSTBElementListDescriptor {
    
    let navigationRules: [RSStepTreeNavigationRule]?
    let resultTransforms: [RSResultTransform]?
    
    // MARK: - Deserialization
    
    required public init?(json: JSON) {
        
        let navigationRulesJSON: [JSON]? = "navigationRules" <~~ json
        self.navigationRules = navigationRulesJSON?.flatMap { RSStepTreeNavigationRule(json: $0) }
        
        let resultTransformsJSON: [JSON]? = "resultTransforms" <~~ json
        self.resultTransforms = resultTransformsJSON?.flatMap { RSResultTransform(json: $0) }
        
        super.init(json: json)
    }

}
