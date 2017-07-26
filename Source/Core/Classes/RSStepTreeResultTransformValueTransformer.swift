//
//  RSStepTreeResultTransformValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 7/1/17.
//
//

import UIKit
import ResearchKit
import Gloss
import ResearchSuiteResultsProcessor

open class RSStepTreeResultTransformValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "resultTransform" == type
    }
    
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        
        //note that we do not do a recursive search for the childID
        guard let taskResult = context["taskResult"] as? ORKTaskResult,
            let stepResults = taskResult.results as? [ORKStepResult],
            let node = context["node"] as? RSStepTreeBranchNode,
            let childID: String = "childID" <~~ jsonObject,
            let transformID: String = "transformID" <~~ jsonObject,
            let child = node.child(withfullyQualified: childID) as? RSStepTreeBranchNode,
            let resultTransform = child.resultTransforms[transformID] else {
                return nil
        }
        
        //lets create a new task result that selects only the results below child and maps the identifiers
        
        debugPrint(child.fullyQualifiedIdentifier)
        debugPrint(stepResults)
        
        let fullyQualifiedChildIdentifier = child.fullyQualifiedIdentifier
        //filter
        let filteredStepResults = stepResults
            .filter { stepResult in
                return stepResult.identifier.hasPrefix(child.fullyQualifiedIdentifier)
            }
            .map { (stepResult) -> ORKStepResult in
                let stepResultIdentifierComponents = stepResult.identifier.components(separatedBy: ".")
                debugPrint(stepResultIdentifierComponents)
                
                //note that the "child" here is actually a parent of the step
                let childIdentifierComponents = child.fullyQualifiedIdentifier.components(separatedBy: ".")
                debugPrint(childIdentifierComponents)
                let remainingComponents = stepResultIdentifierComponents.dropFirst(childIdentifierComponents.count)
                debugPrint(remainingComponents)
                return ORKStepResult(stepIdentifier: remainingComponents.joined(separator: "."), results: stepResult.results)
        }
        
        //map -> step result w/ new identifier
        
        let filteredTaskResult = ORKTaskResult(taskIdentifier: taskResult.identifier, taskRun: UUID(), outputDirectory: nil)
        filteredTaskResult.results = filteredStepResults
        
        debugPrint(filteredTaskResult)
        
        return RSRPFrontEndService.processResult(
            taskResult: filteredTaskResult,
            resultTransform: resultTransform,
            frontEndTransformers: RSApplicationDelegate.appDelegate.frontEndResultTransformers
        )
        
    }

}
