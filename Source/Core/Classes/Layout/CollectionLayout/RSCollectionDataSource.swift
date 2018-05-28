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

    open let identifier: String
    open let dataSourceIdentifier: String
    open let predicate: RSPredicate?
    open let sortSettings: RSSortSettings?
    
    required public init?(json: JSON) {
        guard let identifier: String = "identifier" <~~ json,
            let dataSourceIdentifier: String = "dataSourceIdentifier" <~~ json else {
            return nil
        }
        
        self.identifier = identifier
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
    
    var identifier: String { get }
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


