//
//  RSStepTreeElementListGenerator.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/1/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

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
