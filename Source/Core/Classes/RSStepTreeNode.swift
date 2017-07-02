//
//  RSStepTreeNode.swift
//  Pods
//
//  Created by James Kizer on 6/30/17.
//
//

import UIKit

open class RSStepTreeNode: NSObject {
    
    let identifier: String
    let identifierPrefix: String
    let type: String
    
    init(identifier: String, identifierPrefix: String, type: String) {
        self.identifier = identifier
        self.identifierPrefix = identifierPrefix
        self.type = type
        super.init()
    }
    
    open override var description: String {
        
        return self.identifierPrefix == "" ? "\(self.identifier): \(self.type)" : "\n\t\(self.identifierPrefix).\(self.identifier): \(self.type)"
        
    }
    
    open func leaves() -> [RSStepTreeLeafNode] {
        return []
    }
    
    open func child(with identifier: String) -> RSStepTreeNode? {
        return nil
    }

}
