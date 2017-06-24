//
//  RSMeasureActivityElement.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ResearchKit
import Gloss
import ResearchSuiteTaskBuilder

public class RSMeasureActivityElement: RSActivityElement {
    
    let measureID: String
    
    required public init?(json: JSON) {
        
        guard let measureID: String = "measureID" <~~ json else {
            return nil
        }
        
        self.measureID = measureID
        super.init(json: json)
        
    }
    
    open override func generateSteps(taskBuilder: RSTBTaskBuilder) -> [ORKStep]? {
        
        
        //TODO: Need to figure out how to inject the Measure Manager into here
        // we need to get the task element assocated with the measure specified
        //by measureID

        return nil
    }

}
