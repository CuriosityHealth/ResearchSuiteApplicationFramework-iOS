//
//  RSActivityManager.swift
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
import ReSwift
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss

open class RSActivityManager: NSObject {
    
    static let defaultActivityElementTransforms: [RSActivityElementTransformer.Type] = [
        RSMeasureActivityElementTransformer.self,
        RSInstructionActivityElementTransformer.self
    ]
    
    let activityElementTransforms: [RSActivityElementTransformer.Type]

    let stepTreeBuilder: RSStepTreeBuilder
    
    init(
        stepTreeBuilder: RSStepTreeBuilder,
        activityElementTransforms: [RSActivityElementTransformer.Type] = RSActivityManager.defaultActivityElementTransforms
        ) {

        self.activityElementTransforms = activityElementTransforms
        self.stepTreeBuilder = stepTreeBuilder
        
        super.init()
    
    }
    
    public func taskForActivity(activity: RSActivity, state: RSState) -> RSTask? {
        
        let nodes = activity.elements.compactMap { (json) -> RSStepTreeNode? in
            return self.transformActivityElementIntoNode(
                jsonObject: json,
                stepTreeBuilder: self.stepTreeBuilder,
                state: state,
                identifierPrefix: activity.identifier
            )
        }
        
        let rootNode = RSStepTreeBranchNode(
            identifier: activity.identifier,
            identifierPrefix: "",
            type: "activity",
            children: nodes,
            navigationRules: nil,
            resultTransforms: nil
        )
        
        let stepTree = RSStepTree(
            identifier: activity.identifier,
            root: rootNode, taskBuilder: self.stepTreeBuilder.rstb,
            state: state,
            shouldHideCancelButton: activity.shouldHideCancelButton
        )
        
        return stepTree
        
    }

    private func transformActivityElementIntoNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, state: RSState, identifierPrefix: String) -> RSStepTreeNode? {
        
        guard let type: String = "type" <~~ jsonObject else {
            return nil
        }
        
        if let predicate: RSPredicate = "predicate" <~~ jsonObject,
            RSPredicateManager.evaluatePredicate(predicate: predicate, state: state, context: [:]) == false {
            return nil
        }
        
        for transformer in self.activityElementTransforms {
            if transformer.supportsType(type: type) {
                return transformer.generateNode(
                    jsonObject: jsonObject,
                    stepTreeBuilder: stepTreeBuilder,
                    state: state,
                    identifierPrefix: identifierPrefix
                )
            }
        }
        
        return nil
        
    }
    
}
