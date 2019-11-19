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

public protocol RSCollectionDataSourceElement: JSONEncodable {
    
    var primaryDate: Date { get }
    var isValid: Bool { get }
    
}

extension LS2ConcreteDatapoint: RSCollectionDataSourceElement {
    public var isValid: Bool {
        return self.header != nil
    }
    
    public var primaryDate: Date {
        return self.header!.acquisitionProvenance.sourceCreationDateTime
    }
    
}

public protocol RSCollectionDataSource {
    
    var identifier: String { get }
    var count: Int? { get }
    //    var updateCallback: ((Int, Int, Int) -> ())? { get set }
    func get(for index: Int) -> RSCollectionDataSourceElement?
    
    func generateDictionary() -> [Int: RSCollectionDataSourceElement]?
    func toArray() -> [RSCollectionDataSourceElement]?
    
    func invalidate()
    
}

