//
//  Collection+Extensions.swift
//  Alamofire
//
//  Created by James Kizer on 6/5/19.
//

import Foundation

public extension Array {
    func isSorted(by areInIncreasingOrder: (Array<Element>.Element, Array<Element>.Element) throws -> Bool) rethrows -> Bool  {
        if self.count <= 1 {
            return true
        }
        
        for i in 1..<self.count {
            let increasing = try areInIncreasingOrder(self[i-1], self[i])
            if increasing == false {
                return false
            }
        }
        return true
    }
}

public extension Collection {
    func compacted<T>() -> [T] where Element == Optional<T> {
        return self.compactMap({$0})
    }
    
    func flattened<T>() -> [T] where Element == [T] {
        return self.flatMap({$0})
    }
}
