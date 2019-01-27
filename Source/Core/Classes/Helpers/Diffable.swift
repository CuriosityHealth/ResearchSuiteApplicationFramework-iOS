//
//  Diffable.swift
//  ResearchSuiteApplicationFramework.common-Development
//
//  Created by James Kizer on 1/14/19.
//

import UIKit

public protocol Diffable: Equatable {
    associatedtype DiffableIdentifierType: Hashable
    var identifier: DiffableIdentifierType { get }
}

extension Diffable {
    //generic diff generation method
    //returns indices of elements that have been removed / added between oldElements, newElements
    //note that there is prbably a wey to do this via DP
    //intuition is that recursive choices may result in duplicate work, and that identical oldList and newList values may result in same work
    //for example, what if we just transpose two values
    private static func diffDeletionInsertionHelper<T: Diffable>(oldList: ArraySlice<(Int, T)>, newList: ArraySlice<(Int, T)>, deletions: [Int], insertions: [Int]) -> ([Int], [Int]) {
        //base cases
        //1) oldList is empty -> add indices from new list to insertions, return
        //2) newList is empty -> add indices from old list to deletions, return
        
        guard let oldHead = oldList.first else {
            let indices = newList.map { $0.0 }
            return (deletions, insertions + indices)
        }
        
        guard let newHead = newList.first else {
            let indices = oldList.map { $0.0 }
            return (deletions + indices, insertions)
        }
        
        //3) head item identifiers match, remove head from both lists, recurse
        if oldHead.1.identifier == newHead.1.identifier {
            let oldTail = oldList.dropFirst()
            let newTail = newList.dropFirst()
            return diffDeletionInsertionHelper(oldList: oldTail, newList: newTail, deletions: deletions, insertions: insertions)
        }
        
        //4) head item identifiers match, fork
        //4a) add head from old list to deletions, recurse
        let oldTail = oldList.dropFirst()
        //    print("removing oldHead, adding it to deletions")
        //    print(oldHead)
        let firstDiffs = diffDeletionInsertionHelper(oldList: oldTail, newList: newList, deletions: deletions + [oldHead.0], insertions: insertions)
        
        
        //4b) add head from new list to insertions, recurse
        let newTail = newList.dropFirst()
        //    print("removing newHead, adding it to insertions")
        //    print(newHead)
        let secondDiffs = diffDeletionInsertionHelper(oldList: oldList, newList: newTail, deletions: deletions, insertions: insertions + [newHead.0])
        
        if (firstDiffs.0.count + firstDiffs.1.count) < (secondDiffs.0.count + secondDiffs.1.count) {
            return firstDiffs
        }
        else {
            return secondDiffs
        }
        
    }
    
    public static func computeDiffs<T: Diffable>(oldList: [T], newList: [T]) -> ([Int], [Int], [Int]) {
        
        //first, compute inserts / deletes
        let enumeratedOldList: [(Int, T)] = oldList.enumerated().map { $0 }
        let enumeratedNewList: [(Int, T)] = newList.enumerated().map { $0 }
        
        let (deletions, insertions) = self.diffDeletionInsertionHelper(oldList: ArraySlice(enumeratedOldList), newList: ArraySlice(enumeratedNewList), deletions: [], insertions: [])
        
        //then, compute mods
        //ignore inserted
        
        //    let insertionSet = Set(insertions)
        let oldMap = Dictionary.init(uniqueKeysWithValues: oldList.map { ($0.identifier, $0) })
        let modifications: [Int] = enumeratedNewList.compactMap { (newPair) -> Int? in
            
            let newDiffable = newPair.1
            
            //first, ensure that identifier is in old map
            guard let oldDiffable = oldMap[newDiffable.identifier] else {
                return nil
            }
            
            //if so, check to see if values have "changed"
            if oldDiffable == newDiffable {
                return nil
            }
            else {
                return newPair.0
            }
            
        }
        
        return (deletions, insertions, modifications)
    }

}

//public struct DiffableTest: Diffable {
//    var identifier: String
//    var value: Int
//
//    typealias DiffableIdentifierType = String
//
//    public static func == (lhs: DiffableTest, rhs: DiffableTest) -> Bool {
//        return lhs.identifier == rhs.identifier && lhs.value == rhs.value
//    }
//}



