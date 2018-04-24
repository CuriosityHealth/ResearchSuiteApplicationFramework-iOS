//
//  RSStepTreeNode.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/30/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchKit

open class RSStepTreeNode: NSObject {
    
    let identifier: String
    let identifierPrefix: String
    let type: String
    let parent: RSStepTreeNode?
    
    init(identifier: String, identifierPrefix: String, type: String, parent: RSStepTreeNode?) {
        self.identifier = identifier
        self.identifierPrefix = identifierPrefix
        self.type = type
        self.parent = parent
        super.init()
    }
    
    open override var description: String {
        
        return self.identifierPrefix == "" ? "\(self.identifier): \(self.type)" : "\n\t\(self.fullyQualifiedIdentifier): \(self.type)"
        
    }
    
    var fullyQualifiedIdentifier: String {
        return "\(self.identifierPrefix).\(self.identifier)"
    }
    
    open func firstLeaf(with result: ORKTaskResult, state: RSState) -> RSStepTreeLeafNode? {
        return nil
    }
    
//    open func leaves() -> [RSStepTreeLeafNode] {
//        return []
//    }
    
    open func child(with identifier: String) -> RSStepTreeNode? {
        return nil
    }

}
