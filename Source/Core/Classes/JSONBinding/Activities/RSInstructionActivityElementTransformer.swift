//
//  RSInstructionActivityElementTransformer.swift
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

public class RSInstructionActivityElementTransformer: RSActivityElementTransformer {
    public static func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, state: RSState, identifierPrefix: String) -> RSStepTreeNode? {
        
        guard let instructionDescriptor = RSTBInstructionStepDescriptor(json: jsonObject) else {
            return nil
        }
        
        return RSStepTreeLeafNode(
            identifier: instructionDescriptor.identifier,
            identifierPrefix: identifierPrefix,
            type: instructionDescriptor.type,
            stepGenerator: { (taskBuilder, identifierPrefix) -> ORKStep? in
//                return taskBuilder.steps(forElement: jsonObject as JsonElement)?.first
                guard let descriptor = RSTBElementDescriptor(json: jsonObject) else {
                    return nil
                }
                
                return taskBuilder.createSteps(forType: descriptor.type, withJsonObject: jsonObject, identifierPrefix: identifierPrefix)?.first
        }
        )
    }

    public static func generateSteps(jsonObject: JSON, taskBuilder: RSTBTaskBuilder, state: RSState) -> [ORKStep]? {
        return taskBuilder.steps(forElement: jsonObject as JsonElement)
    }
    public static func supportsType(type: String) -> Bool {
        return type == "instruction"
    }
}
