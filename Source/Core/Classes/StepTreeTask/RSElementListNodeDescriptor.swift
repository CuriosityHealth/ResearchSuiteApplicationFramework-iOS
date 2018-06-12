//
//  RSElementListNodeDescriptor.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/1/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import Gloss

open class RSElementListNodeDescriptor: RSTBElementListDescriptor {
    
    let navigationRules: [RSStepTreeNavigationRule]?
    let resultTransforms: [RSResultTransform]?
    let valueMapping: [String: JSON]?
    
    // MARK: - Deserialization
    
    required public init?(json: JSON) {
        
        let navigationRulesJSON: [JSON]? = "navigationRules" <~~ json
        self.navigationRules = navigationRulesJSON?.compactMap { RSStepTreeNavigationRule(json: $0) }
        
        let resultTransformsJSON: [JSON]? = "resultTransforms" <~~ json
        self.resultTransforms = resultTransformsJSON?.compactMap { RSResultTransform(json: $0) }
        
        self.valueMapping = "valueMapping" <~~ json
        
        super.init(json: json)
    }

}
