//
//  RSStepTreeBranchNode.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/30/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchKit
import Gloss

open class RSStepTreeBranchNode: RSStepTreeNode {
    
    private var _children: [RSStepTreeNode] = []
    public var children: [RSStepTreeNode] {
        return self._children
    }
    private var childMap: [String: RSStepTreeNode] = [:]
    
    private let navigationRules: [String: RSStepTreeNavigationRule]
    public let resultTransforms: [String: RSResultTransform]
    public let valueMapping: [String: JSON]
    
    public init(
        identifier: String,
        identifierPrefix: String,
        type: String,
        children: [RSStepTreeNode],
        parent: RSStepTreeNode?,
        navigationRules: [RSStepTreeNavigationRule]?,
        resultTransforms: [RSResultTransform]?,
        valueMapping: [String: JSON]?
        ) {
        var navRulesMap: [String: RSStepTreeNavigationRule] = [:]
        navigationRules?.forEach { (rule) in
            assert(navRulesMap[rule.trigger] == nil, "rules cannot have duplicate triggers")
            navRulesMap[rule.trigger] = rule
        }
        self.navigationRules = navRulesMap
        
        var resultTransformMap: [String: RSResultTransform] = [:]
        resultTransforms?.forEach({ (transform) in
            assert(resultTransformMap[transform.identifier] == nil, "rules cannot have duplicate transforms")
            resultTransformMap[transform.identifier] = transform
        })
        
        self.resultTransforms = resultTransformMap
        self.valueMapping = valueMapping ?? [:]
        super.init(identifier: identifier, identifierPrefix: identifierPrefix, type: type, parent: parent)
        
        self.setChildren(children: children)
    }
    
    public func setChildren(children: [RSStepTreeNode]) {
        self._children = children
        var childMap: [String: RSStepTreeNode] = [:]
        self.children.forEach { (child) in
            
            assert(childMap[child.identifier] == nil, "children cannot have duplicate names: \(child.identifier)")
            childMap[child.identifier] = child
            
        }
        
        self.childMap = childMap
    }
    
    open override var description: String {
        
        return super.description + children.reduce("", { (description, child) -> String in
            return description + "\(child)"
        })
        
    }
    
    open override func firstLeaf(with result: ORKTaskResult, state: RSState) -> RSStepTreeLeafNode? {
        
        assert(children.count > 0, "branch nodes must have children")
        
        if let startingNavRule = self.navigationRules["START"],
            let node = self.child(for: startingNavRule, with: result, state: state) {
            return node.firstLeaf(with: result, state: state)
        }
        
        for child in self.children {
            if let leaf = child.firstLeaf(with: result, state: state) {
                return leaf
            }
        }
        return nil
    }
    
//    open override func leaves() -> [RSStepTreeLeafNode] {
//        return Array(self.children.map { $0.leaves() }.joined())
//    }
    
    open override func child(with identifier: String) -> RSStepTreeNode? {
        let child = self.childMap[identifier]
        return child
    }
    
    open func child(withfullyQualified identifier: String) -> RSStepTreeNode? {
        guard identifier != "" else {
            return nil
        }
        let identifierStack = identifier.components(separatedBy: ".")
        
        guard let head = identifierStack.first,
            let child = self.childMap[head] else {
                return nil
        }
        
        let tail = Array(identifierStack.dropFirst())
        
        if tail.count > 0 {
            guard let child = child as? RSStepTreeBranchNode else {
                return  nil
            }
            
            return child.child(withfullyQualified: tail.joined(separator: "."))
        }
        else {
            return child
        }
        
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
        
        let context: [String: AnyObject] = ["taskResult": result, "node": self as AnyObject]
        
        let successfulRuleOpt: RSStepTreeConditionalNavigationRule? = navigationRule.conditionalNavigation.first {
            return RSPredicateManager.evaluatePredicate(predicate: $0.predicate, state: state, context: context)
        }
        
        guard let successfulRule = successfulRuleOpt else {
            return self.childMap[navigationRule.destination]
        }
        
        return self.childMap[successfulRule.destination]
    }
    

}
