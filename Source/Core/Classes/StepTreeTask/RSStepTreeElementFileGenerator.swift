//
//  RSStepTreeElementFileGenerator.swift
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
import ResearchSuiteTaskBuilder

open class RSStepTreeElementFileGenerator: RSStepTreeNodeGenerator {
    
    open static func getJSON(forURL url: URL) -> JSON? {

        guard let fileContent = try? Data(contentsOf: url)
            else {
                assertionFailure("Unable to create NSData with content of file \(url)")
                return nil
        }
        
        guard let json = (try? JSONSerialization.jsonObject(with: fileContent, options: JSONSerialization.ReadingOptions.mutableContainers)) as? JSON else {
            return nil
        }
        
        return json
    }
    
    open static func loadJSONElement(descriptor: RSStepTreeElementFileDescriptor, stepTreeBuilder: RSStepTreeBuilder) -> JSON? {
        
        //first, try to load from URL (base + path)
        if let urlBase = stepTreeBuilder.rstb.helper.stateHelper?.valueInState(forKey: descriptor.elementURLBaseKey) as? String,
            let urlPath = descriptor.elementURLPath,
            let url = URL(string: urlBase + urlPath) {
            
            return RSStepTreeElementFileGenerator.getJSON(forURL: url)
        }
        else if let filename = descriptor.elementFilename {
            return stepTreeBuilder.rstb.helper.getJson(forFilename: filename) as? JSON
        }
        else {
            return nil
        }
    }
    
    open static func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, identifierPrefix: String) -> RSStepTreeNode? {
        guard let descriptor = RSStepTreeElementFileDescriptor(json: jsonObject),
            let jsonElement = RSStepTreeElementFileGenerator.loadJSONElement(descriptor: descriptor, stepTreeBuilder: stepTreeBuilder) else {
            return nil
        }
        
        //recurse
        let child = stepTreeBuilder.node(json: jsonElement, identifierPrefix: "\(identifierPrefix).\(descriptor.identifier)")
        let children: [RSStepTreeNode] = (child != nil) ? [child!] : []
        
        let node = RSStepTreeBranchNode(
            identifier: descriptor.identifier,
            identifierPrefix: identifierPrefix,
            type: descriptor.type,
            children: children,
            navigationRules: nil,
            resultTransforms: nil
        )
        
        return node
    }
    
    open static func supportsType(type: String) -> Bool {
        return "elementFile" == type
    }

}
