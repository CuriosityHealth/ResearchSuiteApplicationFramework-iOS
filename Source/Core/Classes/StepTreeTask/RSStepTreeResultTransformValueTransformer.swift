//
//  RSStepTreeResultTransformValueTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/1/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
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
        
//        debugPrint(child.fullyQualifiedIdentifier)
//        debugPrint(stepResults)
        
//        let fullyQualifiedChildIdentifier = child.fullyQualifiedIdentifier
        //filter
        let filteredStepResults = stepResults
            .filter { stepResult in
                return stepResult.identifier.hasPrefix(child.fullyQualifiedIdentifier)
            }
            .map { (stepResult) -> ORKStepResult in
                let stepResultIdentifierComponents = stepResult.identifier.components(separatedBy: ".")
//                debugPrint(stepResultIdentifierComponents)
                
                //note that the "child" here is actually a parent of the step
                let childIdentifierComponents = child.fullyQualifiedIdentifier.components(separatedBy: ".")
//                debugPrint(childIdentifierComponents)
                let remainingComponents = stepResultIdentifierComponents.dropFirst(childIdentifierComponents.count)
//                debugPrint(remainingComponents)
                //stepResult.results?.forEach { debugPrint($0) }
                //NOTE: This copies the nested results, the Result object that inherits from
                //ORKResult may need to override the copy method. See RSEnhancedMultipleChoiceResult in RSExtensions
                let newStepResult = ORKStepResult(stepIdentifier: remainingComponents.joined(separator: "."), results: stepResult.results)
                //newStepResult.results?.forEach { debugPrint($0) }
                return newStepResult
        }
        
        //map -> step result w/ new identifier
        
        let filteredTaskResult = ORKTaskResult(taskIdentifier: taskResult.identifier, taskRun: UUID(), outputDirectory: nil)
        filteredTaskResult.results = filteredStepResults
        
//        debugPrint(filteredTaskResult)
        
        return RSRPFrontEndService.processResult(
            taskResult: filteredTaskResult,
            resultTransform: resultTransform,
            frontEndTransformers: RSApplicationDelegate.appDelegate.frontEndResultTransformers
        )
        
    }

}
