//
//  RSMeasureActivityElementTransformer.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ResearchSuiteTaskBuilder
import ResearchKit
import Gloss

public class RSMeasureActivityElementTransformer: RSActivityElementTransformer {
    
    public static func generateSteps(jsonObject: JSON, taskBuilder: RSTBTaskBuilder, state: RSState) -> [ORKStep]? {
        
        
        guard let measureID: String = "measureID" <~~ jsonObject,
            let measure = RSStateSelectors.measure(state, for: measureID) else {
                return nil
        }
        
        return taskBuilder.steps(forElement: measure.taskElement as JsonElement)
    }
    
    public static func supportsType(type: String) -> Bool {
        return type == "measure"
    }

}
