//
//  RSStepTreeLeafNode.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/30/17.
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
import ResearchSuiteTaskBuilder
import ResearchKit

open class RSStepTreeLeafNode: RSStepTreeNode {
    
    let stepGenerator: (RSTBTaskBuilder, String) -> ORKStep?
    public init(
        identifier: String,
        identifierPrefix: String,
        type: String,
        stepGenerator: @escaping (RSTBTaskBuilder, String) -> ORKStep?
        ) {
        self.stepGenerator = stepGenerator
        super.init(identifier: identifier, identifierPrefix: identifierPrefix, type: type)
    }
    
    open func step(taskBuilder: RSTBTaskBuilder) -> ORKStep? {
        return self.stepGenerator(taskBuilder, self.identifierPrefix)
    }
    
    open override func leaves() -> [RSStepTreeLeafNode] {
        return [self]
    }
    
//    open override var description: String {
//        
//        return self.identifierPrefix == "" ? "\(self.identifier): \(self.type)" : "\n\t\(self.identifierPrefix).\(self.identifier): \(self.type)"
//        
//    }
    
    

}
