//
//  RSInstructionActivityElementTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import ResearchKit
import Gloss

public class RSInstructionActivityElementTransformer: RSActivityElementTransformer {
    public static func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, state: RSState, identifierPrefix: String, parent: RSStepTreeNode?) -> RSStepTreeNode? {
        
        guard let instructionDescriptor = RSTBInstructionStepDescriptor(json: jsonObject) else {
            return nil
        }
        
        return RSStepTreeLeafNode(
            identifier: instructionDescriptor.identifier,
            identifierPrefix: identifierPrefix,
            type: instructionDescriptor.type,
            parent: parent,
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
