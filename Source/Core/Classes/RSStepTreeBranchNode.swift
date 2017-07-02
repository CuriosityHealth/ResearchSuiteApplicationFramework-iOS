//
//  RSStepTreeBranchNode.swift
//  Pods
//
//  Created by James Kizer on 6/30/17.
//
//

import UIKit
import ResearchKit

open class RSStepTreeBranchNode: RSStepTreeNode {
    
    let children: [RSStepTreeNode]
    let childMap: [String: RSStepTreeNode]
    let navigationRules: [String: RSStepTreeNavigationRule]
    let resultTransforms: [String: RSResultTransform]
    
    public init(
        identifier: String,
        identifierPrefix: String,
        type: String,
        children: [RSStepTreeNode],
        navigationRules: [RSStepTreeNavigationRule]?,
        resultTransforms: [RSResultTransform]?
        ) {
        self.children = children
        var childMap: [String: RSStepTreeNode] = [:]
        self.children.forEach { (child) in
            
            assert(childMap[child.identifier] == nil, "children cannot have duplicate names")
            childMap[child.identifier] = child
            
        }
        
        self.childMap = childMap
        var navRulesMap: [String: RSStepTreeNavigationRule] = [:]
        navigationRules?.forEach { (rule) in
            assert(navRulesMap[rule.trigger] == nil, "rules cannot have duplicate triggers")
            navRulesMap[rule.trigger] = rule
        }
        self.navigationRules = navRulesMap
        
        var resultTransformMap: [String: RSResultTransform] = [:]
        resultTransforms?.forEach({ (transform) in
            assert(resultTransformMap[transform.identifier] == nil, "rules cannot have duplicate triggers")
            resultTransformMap[transform.identifier] = transform
        })
        
        self.resultTransforms = resultTransformMap
        super.init(identifier: identifier, identifierPrefix: identifierPrefix, type: type)
    }
    
    open override var description: String {
        
        return super.description + children.reduce("", { (description, child) -> String in
            return description + "\(child)"
        })
        
    }
    
    open override func leaves() -> [RSStepTreeLeafNode] {
        return Array(self.children.map { $0.leaves() }.joined())
    }
    
    open override func child(with identifier: String) -> RSStepTreeNode? {
        let child = self.childMap[identifier]
        return child
    }
    
    
    /**
     Gets the child immediately following child
     
     - Parameter child: the child
     
     - Returns: the next child (if one exists). nil implies that we've reached the end
     */
    open func child(after child: RSStepTreeNode?, with result: ORKTaskResult, state: RSState) -> RSStepTreeNode? {
        guard let child = child else {
            return self.children.first
        }
        
        //check to see if there are any nav rules for this node
        //otherwise, just go to the next step
        if let navRule = self.navigationRules[child.identifier] {
            return self.child(for: navRule, with: result, state: state)
        }
        else {
            guard let childIndex = self.children.index(of: child) else {
                assertionFailure("Can't find child! This is a programming error!")
                return nil
            }
            
            let nextIndex = self.children.index(after: childIndex)
            return nextIndex < self.children.endIndex ? self.children[nextIndex] : nil
        }
        
    }
    
    open func child(for navigationRule: RSStepTreeNavigationRule, with result: ORKTaskResult, state: RSState) -> RSStepTreeNode? {
        
        let context: [String: AnyObject] = ["taskResult": result, "childMap": self.childMap as AnyObject]
        
        let successfulRuleOpt: RSStepTreeConditionalNavigationRule? = navigationRule.conditionalNavigation.first {
            return RSActivityManager.evaluatePredicate(predicate: $0.predicate, state: state, context: context)
        }
        
        guard let successfulRule = successfulRuleOpt else {
            return self.childMap[navigationRule.destination]
        }
        
        return self.childMap[successfulRule.destination]
    }
    
    
    
    
    
    
    
}
