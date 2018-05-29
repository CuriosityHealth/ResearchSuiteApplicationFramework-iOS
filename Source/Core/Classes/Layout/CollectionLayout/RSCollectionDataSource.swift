//
//  RSDatabaseCollectionDataSource.swift
//  Pods
//
//  Created by James Kizer on 5/17/18.
//

import UIKit
import Gloss
import LS2SDK

//public protocol RSCollectionDataSource {
//
//    associatedtype Element
//    var count: Int? { get }
//    //    var updateCallback: ((Int, Int, Int) -> ())? { get set }
//    func get(for index: Int) -> Element?
//
//    func generateDictionary() -> [Int: Element]?
//    func toArray() -> [Element]?
//
//}

public protocol RSCollectionDataSource {
    
    var identifier: String { get }
    var count: Int? { get }
    //    var updateCallback: ((Int, Int, Int) -> ())? { get set }
    func get(for index: Int) -> LS2Datapoint?
    
    func generateDictionary() -> [Int: LS2Datapoint]?
    func toArray() -> [LS2Datapoint]?
    
    
    
}

