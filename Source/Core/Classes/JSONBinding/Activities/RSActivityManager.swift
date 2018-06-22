//
//  RSActivityManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss

public protocol RSActivityGenerator {
    static func supportsType(type: String?) -> Bool
    static func generate(jsonObject: JSON, activityManager: RSActivityManager, state: RSState) -> RSActivity?
}

open class RSActivityManager: NSObject {
    
    static let defaultActivityElementTransforms: [RSActivityElementTransformer.Type] = [
        RSMeasureActivityElementTransformer.self,
        RSInstructionActivityElementTransformer.self
    ]
    
    static let defaultActivityGenerators: [RSActivityGenerator.Type] = [
        RSActivityFileGenerator.self,
        RSStandardActivityGenerator.self
    ]
    
    let activityElementTransforms: [RSActivityElementTransformer.Type]
    let activityGenerators: [RSActivityGenerator.Type]
    
    init(
        activityGenerators: [RSActivityGenerator.Type] = RSActivityManager.defaultActivityGenerators,
        activityElementTransforms: [RSActivityElementTransformer.Type] = RSActivityManager.defaultActivityElementTransforms
        ) {

        self.activityElementTransforms = activityElementTransforms
        self.activityGenerators = activityGenerators
        
        super.init()
    
    }
    
    public func taskForActivity(activity: RSActivity, state: RSState, stepTreeBuilder: RSStepTreeBuilder) -> RSTask? {
        
        let rootNode = RSStepTreeBranchNode(
            identifier: activity.identifier,
            identifierPrefix: "",
            type: "activity",
            children: [],
            parent: nil,
            navigationRules: nil,
            resultTransforms: nil,
            valueMapping: nil
        )
        
        let nodes = activity.elements.compactMap { (json) -> RSStepTreeNode? in
            return self.transformActivityElementIntoNode(
                jsonObject: json,
                stepTreeBuilder: stepTreeBuilder,
                state: state,
                identifierPrefix: activity.identifier,
                parent: rootNode
            )
        }
        
        rootNode.setChildren(children: nodes)
        
//        let rootNode = RSStepTreeBranchNode(
//            identifier: activity.identifier,
//            identifierPrefix: "",
//            type: "activity",
//            children: nodes,
//            navigationRules: nil,
//            resultTransforms: nil
//        )
        
        let stepTree = RSStepTree(
            identifier: activity.identifier,
            root: rootNode,
            taskBuilder: stepTreeBuilder.rstb,
            state: state,
            shouldHideCancelButton: activity.shouldHideCancelButton
        )
        
        return stepTree
        
    }

    private func transformActivityElementIntoNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, state: RSState, identifierPrefix: String, parent: RSStepTreeNode?) -> RSStepTreeNode? {
        
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
                    identifierPrefix: identifierPrefix,
                    parent: parent
                )
            }
        }
        
        return nil
        
    }
    
    public func generate(jsonObject: JSON, state: RSState) -> RSActivity? {
        
        let type: String? = "type" <~~ jsonObject
        
        for generator in self.activityGenerators {
            if generator.supportsType(type: type),
                let activity = generator.generate(jsonObject: jsonObject, activityManager: self, state: state) {
                return activity
            }
        }
        return nil
    }
    
}
