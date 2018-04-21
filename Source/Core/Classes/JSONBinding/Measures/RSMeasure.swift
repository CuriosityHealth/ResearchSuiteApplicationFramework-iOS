//
//  RSMeasure.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss
import ResearchSuiteResultsProcessor

public class RSMeasure: Gloss.JSONDecodable {
    
    public let identifier: String
    public let taskElement: JSON
    private let resultTransforms: [String: RSResultTransform]
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let taskElement: JSON = "taskElement" <~~ json,
            let resultTransformList: [RSResultTransform] = "resultTransforms" <~~ json else {
            return nil
        }
        
        self.identifier = identifier
        self.taskElement = taskElement
        
        var resultTransformMap: [String: RSResultTransform] = [:]
        resultTransformList.forEach { (transform) in
            resultTransformMap[transform.identifier] = transform
        }
        
        self.resultTransforms = resultTransformMap
    }
    
    public func resultTransform(for identifier: String) -> RSResultTransform? {
        return self.resultTransforms[identifier]
    }

}
