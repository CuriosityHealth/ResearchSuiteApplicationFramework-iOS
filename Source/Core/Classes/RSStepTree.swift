//
//  RSStepTree.swift
//  Pods
//
//  Created by James Kizer on 6/30/17.
//
//

import UIKit
import ResearchKit

open class RSStepTree: NSObject, ORKTask {
    
    open let identifier: String
    let root: RSStepTreeNode
    public init(identifier: String, root: RSStepTreeNode) {
        self.identifier = identifier
        self.root = root
    }
    
    open func step(withIdentifier identifier: String) -> ORKStep? {
        
        return nil
        
    }
    
    open func step(after step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        
        return nil
        
    }
    
    open func step(before step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        
        return nil
        
    }
    
    open override var description: String {
        return "\n\tstep tree identifier: \(self.identifier)" +
            "\n\(self.root)"
        
    }
    
    

}
