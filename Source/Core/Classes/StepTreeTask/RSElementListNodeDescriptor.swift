//
//  RSElementListNodeDescriptor.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/1/17.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import ResearchSuiteTaskBuilder
import Gloss

open class RSElementListNodeDescriptor: RSTBElementListDescriptor {
    
    let navigationRules: [RSStepTreeNavigationRule]?
    let resultTransforms: [RSResultTransform]?
    
    // MARK: - Deserialization
    
    required public init?(json: JSON) {
        
        let navigationRulesJSON: [JSON]? = "navigationRules" <~~ json
        self.navigationRules = navigationRulesJSON?.compactMap { RSStepTreeNavigationRule(json: $0) }
        
        let resultTransformsJSON: [JSON]? = "resultTransforms" <~~ json
        self.resultTransforms = resultTransformsJSON?.compactMap { RSResultTransform(json: $0) }
        
        super.init(json: json)
    }

}
