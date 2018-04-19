//
//  RSStepTree.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/30/17.
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
import ResearchKit
import ResearchSuiteTaskBuilder

open class RSStepTree: NSObject, ORKTask, RSTask {
    
    open let identifier: String
    let root: RSStepTreeNode
    let taskBuilder: RSTBTaskBuilder
    let state: RSState
    let leafIdentifiers: [String]
    open let shouldHideCancelButton: Bool
    public init(identifier: String, root: RSStepTreeNode, taskBuilder: RSTBTaskBuilder, state: RSState, shouldHideCancelButton: Bool = false) {
        self.identifier = identifier
        self.root = root
        self.leafIdentifiers = self.root.leaves().map { $0.fullyQualifiedIdentifier }
        self.taskBuilder = taskBuilder
        self.state = state
        self.shouldHideCancelButton = shouldHideCancelButton
    }
    
    open func step(withIdentifier identifier: String) -> ORKStep? {
        
        guard let node = self.node(for: identifier) as? RSStepTreeLeafNode else {
            return nil
        }
        
        return node.step(taskBuilder: self.taskBuilder)
        
    }
    
    open func step(after step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        
//        debugPrint(step)
        //if step is nil, select first leaf node and convert to step
        let currentNode = self.node(for: step?.identifier)
        guard let nextNode = self.leafNode(after: currentNode, with: result) else {
            return nil
        }
        
        let step = nextNode.step(taskBuilder: self.taskBuilder)
//        debugPrint(step)
        return step
    }
    
    //for now, just use the RK implementation
    //seems to be working
    open func step(before step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        
        guard let step = step,
            let stepResults = result.results else {
            return nil
        }

        let reversedStepEnumeratedStepResults = Array(stepResults.enumerated().reversed())
        let firstPair = reversedStepEnumeratedStepResults.first { (offset, stepResult) -> Bool in
            return stepResult.identifier == step.identifier
        }
        
        guard let index = firstPair?.offset else {
            return nil
        }
        
//        debugPrint(index)
        let previousIndex = stepResults.index(before: index)
//        debugPrint(previousIndex)
        let previousStep: ORKStep? = {
            
            if previousIndex >= stepResults.startIndex {
                let identifier: String = stepResults[previousIndex].identifier
                return self.step(withIdentifier: identifier)
            }
            
            return nil
        }()
        return previousStep
        
    }
    
    open func progress(ofCurrentStep step: ORKStep, with result: ORKTaskResult) -> ORKTaskProgress {
        
        guard let index = self.leafIdentifiers.index(of: step.identifier) else {
            return ORKTaskProgressMake(0, 0)
        }
        
        return ORKTaskProgressMake(UInt(index), UInt(self.leafIdentifiers.count))
    }
    
    open override var description: String {
        return "\n\tstep tree identifier: \(self.identifier)" +
            "\n\(self.root)"
        
    }
    
    open func node(for identifier: String?) -> RSStepTreeNode? {
        //need to discard the root's identifier
        guard identifier != "",
            let identifierStack = identifier?.components(separatedBy: "."),
            identifierStack.count > 0 else {
            return nil
        }
        
        if (identifierStack.count == 1) {
            assert(identifierStack[0] == self.root.identifier)
            return self.root
        }
        
        guard identifierStack.count > 1 else {
            return nil
        }

        
        let head = identifierStack[1]
        let tail = Array(identifierStack.dropFirst(2))
        
        return self.node(node: self.root, head: head, tail: tail)
    }
    
    open func node(node: RSStepTreeNode, head: String, tail: [String]) -> RSStepTreeNode? {
        guard let childNode = node.child(with: head) else {
            return nil
        }

        if let newHead = tail.first {
            let newTail = Array(tail.dropFirst())
            return self.node(node: childNode, head: newHead, tail: newTail)
        }
        else {
            return childNode
        }
    }
    
    open func leafNode(after node: RSStepTreeNode?, with result: ORKTaskResult) -> RSStepTreeLeafNode? {
        
        guard let node = node else {
            return self.root.leaves().first
        }
        
        //get parent
        guard let parent = self.node(for: node.identifierPrefix) as? RSStepTreeBranchNode else {
            return nil
        }

        
        //ask for its next child based on result
        //if the next child is a leaf, simply return it
        //otherwise, get the first leaf of the branch node and return that
        //COMMENTARY: we scope navigation rules to the same level,
        //i.e., we don't want children to have knowledge of the result of other parts of the tree
        //therefore, we should be able to select the first leaf below the branch
        if let nextChild = parent.child(after: node, with: result, state: self.state) {
            switch nextChild {
            case let leaf as RSStepTreeLeafNode:
                return leaf
            case let branch as RSStepTreeBranchNode:
                return branch.leaves().first
            default:
                return nil
            }
        }
        else {
            //if this parent doesn't have a next child, go up the tree
            return self.leafNode(after: parent, with: result)
        }
    
        
    }

    
    
    
    
    

}
