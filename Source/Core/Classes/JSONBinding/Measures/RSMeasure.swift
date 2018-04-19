//
//  RSMeasure.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
