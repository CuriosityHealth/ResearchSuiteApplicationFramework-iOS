//
//  RSStepTreeElementListGenerator.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/1/17.
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

open class RSStepTreeElementListGenerator: RSStepTreeNodeGenerator {

    open static func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, identifierPrefix: String) -> RSStepTreeNode? {
//        debugPrint(jsonObject)
        guard let descriptor = RSElementListNodeDescriptor(json: jsonObject) else {
            return nil
        }
        
        //recurse
        let children: [RSStepTreeNode] = descriptor.elementList.compactMap { json in
            let child = stepTreeBuilder.node(json: json, identifierPrefix: "\(identifierPrefix).\(descriptor.identifier)")
            return child
        }
        
        let node = RSStepTreeBranchNode(
            identifier: descriptor.identifier,
            identifierPrefix: identifierPrefix,
            type: descriptor.type,
            children: children,
            navigationRules: descriptor.navigationRules,
            resultTransforms: descriptor.resultTransforms
        )
        
        return node
    }
    
    open static func supportsType(type: String) -> Bool {
        return "elementList" == type
    }
    
}
