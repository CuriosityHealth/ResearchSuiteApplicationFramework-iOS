//
//  RSCollectionDataSource.swift
//  Pods
//
//  Created by James Kizer on 5/17/18.
//

import UIKit
import Gloss
import LS2SDK

open class RSCollectionDataSourceDescriptor: JSONDecodable {

    let dataSourceIdentifier: String
    let predicate: RSPredicate?
    let sortSettings: RSSortSettings?
    
    required public init?(json: JSON) {
        guard let dataSourceIdentifier: String = "dataSourceIdentifier" <~~ json else {
            return nil
        }
        
        self.dataSourceIdentifier = dataSourceIdentifier
        self.predicate = "predicate" <~~ json
        self.sortSettings = "sort" <~~ json
    }
    
}

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
    
    var count: Int? { get }
    //    var updateCallback: ((Int, Int, Int) -> ())? { get set }
    func get(for index: Int) -> LS2Datapoint?
    
    func generateDictionary() -> [Int: LS2Datapoint]?
    func toArray() -> [LS2Datapoint]?
    
    
    
}

public struct RSSortSettings: JSONDecodable {
    let keyPath: String
    let ascending: Bool
    
    public init?(json: JSON) {
        
        guard let keyPath: String = "keyPath" <~~ json,
            let ascending: Bool = "ascending" <~~ json else {
                return nil
        }
        
        self.keyPath = keyPath
        self.ascending = ascending
    }
    
    public init(keyPath: String, ascending: Bool) {
        self.keyPath = keyPath
        self.ascending = ascending
    }
    
}


