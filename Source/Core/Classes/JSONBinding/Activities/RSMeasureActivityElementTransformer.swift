//
//  RSMeasureActivityElementTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
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
import ResearchKit
import Gloss

public class RSMeasureActivityElementTransformer: RSActivityElementTransformer {
    
    public static func generateSteps(jsonObject: JSON, taskBuilder: RSTBTaskBuilder, state: RSState) -> [ORKStep]? {
        
        guard let measureID: String = "measureID" <~~ jsonObject,
            let measure = RSStateSelectors.measure(state, for: measureID) else {
                return nil
        }
        
        return taskBuilder.steps(forElement: measure.taskElement as JsonElement)
    }
    
    public static func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, state: RSState, identifierPrefix: String) -> RSStepTreeNode? {
        guard let measureID: String = "measureID" <~~ jsonObject,
            let measure = RSStateSelectors.measure(state, for: measureID) else {
                return nil
        }
        
        let child = stepTreeBuilder.node(json: measure.taskElement, identifierPrefix: "\(identifierPrefix).\(measure.identifier)")
        let children = (child != nil) ? [child!] : []
        
        return RSStepTreeBranchNode(
            identifier: measure.identifier,
            identifierPrefix: identifierPrefix,
            type: "measure",
            children: children,
            navigationRules: nil,
            resultTransforms: nil
        )
    }
    
    public static func supportsType(type: String) -> Bool {
        return type == "measure"
    }

}
