//
//  RSActivityManager.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

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
    
    public func taskForActivity(activity: RSActivity, state: RSState) -> ORKTask? {
        
        let nodes = activity.elements.flatMap { (json) -> RSStepTreeNode? in
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
        
        let stepTree = RSStepTree(identifier: activity.identifier, root: rootNode, taskBuilder: self.stepTreeBuilder.rstb, state: state)
        
        debugPrint(stepTree)
        
        return stepTree
        
    }

    private func transformActivityElementIntoNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, state: RSState, identifierPrefix: String) -> RSStepTreeNode? {
        
        guard let type: String = "type" <~~ jsonObject else {
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
    
    public static func evaluatePredicate(predicate: RSPredicate, state: RSState, context: [String: AnyObject]) -> Bool {
        //construct substitution dictionary
        
        let nsPredicate = NSPredicate.init(format: predicate.format)
        
        guard let substitutionsJSON = predicate.substitutions else {
            return nsPredicate.evaluate(with: nil)
        }
        
        var substitutions: [String: Any] = [:]
        
        substitutionsJSON.forEach({ (key: String, value: JSON) in
            
            if let valueConvertible = RSValueManager.processValue(jsonObject:value, state: state, context: context) {
                
                //so we know this is a valid value convertible (i.e., it's been recognized by the state map)
                //we also want to potentially have a null value substituted
                if let value = valueConvertible.evaluate() {
                    substitutions[key] = value
                }
                else {
                    assertionFailure("Added NSNull support for this type")
                    let nilObject: AnyObject? = nil as AnyObject?
                    substitutions[key] = nilObject as Any
                }
                
            }
            
        })
        
        guard substitutions.count == substitutionsJSON.count else {
            return false
        }
        
        return nsPredicate.evaluate(with: nil, substitutionVariables: substitutions)
        
    }
    

}
