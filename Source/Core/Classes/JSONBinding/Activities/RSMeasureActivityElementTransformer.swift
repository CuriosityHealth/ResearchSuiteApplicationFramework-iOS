//
//  RSMeasureActivityElementTransformer.swift
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

public class RSMeasureActivityElementTransformer: RSActivityElementTransformer {
    
    public static func generateSteps(jsonObject: JSON, taskBuilder: RSTBTaskBuilder, state: RSState) -> [ORKStep]? {
        
        guard let measureID: String = "measureID" <~~ jsonObject else {
            return nil
        }
        
        guard let measure = RSStateSelectors.measure(state, for: measureID) else {
            print("Could not load measure \(measureID)")
            assertionFailure("Could not load measure \(measureID)")
            return nil
        }
        
        return taskBuilder.steps(forElement: measure.taskElement as JsonElement)
    }
    
    public static func generateNode(
        jsonObject: JSON,
        stepTreeBuilder: RSStepTreeBuilder,
        state: RSState,
        identifierPrefix: String,
        parent: RSStepTreeNode?
        ) -> RSStepTreeNode? {
        
        guard let measureID: String = "measureID" <~~ jsonObject else {
                return nil
        }
        
        guard let measure = RSStateSelectors.measure(state, for: measureID) else {
                print("Could not load measure \(measureID)")
                assertionFailure("Could not load measure \(measureID)")
                return nil
        }
        
        let branchNode = RSStepTreeBranchNode(
            identifier: measure.identifier,
            identifierPrefix: identifierPrefix,
            type: "measure",
            children: [],
            parent: parent,
            navigationRules: nil,
            resultTransforms: nil,
            valueMapping: nil
        )
        
        guard let child = stepTreeBuilder.node(json: measure.taskElement, identifierPrefix: "\(identifierPrefix).\(measure.identifier)", parent: branchNode) else {
            return nil
        }
        
        branchNode.setChildren(children: [child])
        
        return branchNode
    }
    
    public static func supportsType(type: String) -> Bool {
        return type == "measure"
    }

}
