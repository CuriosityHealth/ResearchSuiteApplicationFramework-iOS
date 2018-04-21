//
//  RSResultTransformValueTransformer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/25/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ResearchKit
import ResearchSuiteResultsProcessor

open class RSResultTransformValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "resultTransform" == type
    }
    
//    static func printAllFirstResults(taskResult: ORKTaskResult) {
//        taskResult.results?.forEach({ (result) in
//            
//            if  let stepResult = result as? ORKStepResult,
//                let firstResult = stepResult.firstResult {
//                debugPrint(firstResult)
//            }
//        })
//    }
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> ValueConvertible? {
        
        guard let taskResult = context["taskResult"] as? ORKTaskResult,
            let stepResults = taskResult.results as? [ORKStepResult],
            let measureID: String = "measureID" <~~ jsonObject,
            let transformID: String = "transformID" <~~ jsonObject,
            let measure: RSMeasure = RSStateSelectors.measure(state, for: measureID),
            let resultTransform = measure.resultTransform(for: transformID) else {
            return nil
        }
        
        let prefix = "\(taskResult.identifier).\(measureID)"
        
//        debugPrint(taskResult)
        
//        printAllFirstResults(taskResult: taskResult)
        
        //filter
        let filteredStepResults = stepResults
            .filter { $0.identifier.hasPrefix(prefix) }
            .map { (stepResult) -> ORKStepResult in
                let stepResultIdentifierComponents = stepResult.identifier.components(separatedBy: ".")
//                debugPrint(stepResultIdentifierComponents)
                
                //note that the "child" here is actually a parent of the step
                let prefixComponents = prefix.components(separatedBy: ".")
//                debugPrint(prefixComponents)
                let remainingComponents = stepResultIdentifierComponents.dropFirst(prefixComponents.count)
//                debugPrint(remainingComponents)
                
                return ORKStepResult(stepIdentifier: remainingComponents.joined(separator: "."), results: stepResult.results)
                
//                return ORKStepResult(stepIdentifier: remainingComponents.joined(separator: "."), results: Array(stepResult.results ?? []))
        }
        
        //map -> step result w/ new identifier
        
        let filteredTaskResult = ORKTaskResult(taskIdentifier: taskResult.identifier, taskRun: UUID(), outputDirectory: nil)
        filteredTaskResult.results = filteredStepResults
        
//        debugPrint(filteredTaskResult)
        
//        printAllFirstResults(taskResult: filteredTaskResult)
        
        //select and map results
        
        return RSRPFrontEndService.processResult(
            taskResult: filteredTaskResult,
            resultTransform: resultTransform,
            frontEndTransformers: RSApplicationDelegate.appDelegate.frontEndResultTransformers
        )
        
    }

}

extension RSRPIntermediateResult: ValueConvertible {
    @objc open func evaluate() -> AnyObject? {
        return self
    }
}
