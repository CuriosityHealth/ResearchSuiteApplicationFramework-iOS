//
//  RSStepTreeElementFileGenerator.swift
//  Pods
//
//  Created by James Kizer on 7/1/17.
//
//

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
