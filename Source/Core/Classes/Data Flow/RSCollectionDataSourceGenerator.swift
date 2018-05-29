//
//  RSCollectionDataSourceGenerator.swift
//  Pods
//
//  Created by James Kizer on 5/28/18.
//

import UIKit

public protocol RSCollectionDataSourceGenerator {
    
    static func supportsType(type: String) -> Bool
    
    static func generateCollectionDataSource(
        dataSourceDescriptor: RSCollectionDataSourceDescriptor,
        dataSourceManager: RSCollectionDataSourceManager,
        state: RSState,
        context: [String: AnyObject]) -> RSCollectionDataSource?
    
    static func generateCollectionDataSource(
        dataSourceDescriptor: RSCollectionDataSourceDescriptor,
        dataSourceManager: RSCollectionDataSourceManager,
        state: RSState,
        context: [String: AnyObject],
        readyCallback: @escaping (RSCollectionDataSource)->(),
        updateCallback: @escaping ((RSCollectionDataSource, [Int], [Int], [Int]) -> ())) -> RSCollectionDataSource?

}
