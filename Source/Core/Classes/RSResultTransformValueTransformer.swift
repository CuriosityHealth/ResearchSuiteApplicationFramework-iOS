//
//  RSResultTransformValueTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/25/17.
//
//

import UIKit
import Gloss
import ResearchKit
import ResearchSuiteResultsProcessor

open class RSResultTransformValueTransformer: RSValueTransformer {
    
    public static func supportsType(type: String) -> Bool {
        return "resultTransform" == type
    }
    
    
    public static func generateValue(jsonObject: JSON, state: RSState, context: [String: AnyObject]) -> AnyObject? {
        
        guard let taskResult = context["taskResult"] as? ORKTaskResult,
            let measureID: String = "measureID" <~~ jsonObject,
            let transformID: String = "transformID" <~~ jsonObject,
            let measure: RSMeasure = RSStateSelectors.measure(state, for: measureID),
            let resultTransform = measure.resultTransform(for: transformID) else {
            return nil
        }
        
        return RSRPFrontEndService.processResult(
            taskResult: taskResult,
            resultTransform: resultTransform,
            frontEndTransformers: RSApplicationDelegate.appDelegate.frontEndResultTransformers
        )
        
    }

}
