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
    
    open static func generateNode(jsonObject: JSON, stepTreeBuilder: RSStepTreeBuilder, identifierPrefix: String) -> RSStepTreeNode? {
        guard let descriptor = RSTBElementFileDescriptor(json: jsonObject),
            let jsonElement = stepTreeBuilder.rstb.helper.getJson(forFilename: descriptor.elementFilename) as? JSON else {
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
