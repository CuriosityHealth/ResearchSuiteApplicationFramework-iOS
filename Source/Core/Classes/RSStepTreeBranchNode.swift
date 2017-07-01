//
//  RSStepTreeBranchNode.swift
//  Pods
//
//  Created by James Kizer on 6/30/17.
//
//

import UIKit

open class RSStepTreeBranchNode: RSStepTreeNode {
    
    let children: [RSStepTreeNode]
    let navigationRules: [RSStepTreeNavigationRule]
    let resultTransforms: [RSResultTransform]
    
    init(
        identifier: String,
        identifierPrefix: String,
        type: String,
        children: [RSStepTreeNode],
        navigationRules: [RSStepTreeNavigationRule]?,
        resultTransforms: [RSResultTransform]?
        ) {
        self.children = children
        self.navigationRules = navigationRules ?? []
        self.resultTransforms = resultTransforms ?? []
        super.init(identifier: identifier, identifierPrefix: identifierPrefix, type: type)
    }
    
    open override var description: String {
        
        return super.description + children.reduce("", { (description, child) -> String in
            return description + "\(child)"
        })
        
    }
    
    
    
    
    
}
