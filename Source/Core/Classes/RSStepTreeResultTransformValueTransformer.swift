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
        
        guard let taskResult = context["taskResult"] as? ORKTaskResult,
            let childID: String = "childID" <~~ jsonObject,
            let transformID: String = "transformID" <~~ jsonObject,
            let childMap = context["childMap"] as? [String: RSStepTreeNode],
            let child = childMap[childID] as? RSStepTreeBranchNode,
            let resultTransform = child.resultTransforms[transformID] else {
                return nil
        }
        
        return RSRPFrontEndService.processResult(
            taskResult: taskResult,
            resultTransform: resultTransform,
            frontEndTransformers: RSApplicationDelegate.appDelegate.frontEndResultTransformers
        )
        
    }

}
