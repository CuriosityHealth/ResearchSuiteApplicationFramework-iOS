//
//  RSDatabaseCollectionDataSourceGenerator.swift
//  Pods
//
//  Created by James Kizer on 5/29/18.
//

import UIKit

open class RSDatabaseCollectionDataSourceGenerator: RSCollectionDataSourceGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "database"
    }
    
    public static func generateCollectionDataSource(dataSourceDescriptor: RSCollectionDataSourceDescriptor, dataSourceManager: RSCollectionDataSourceManager, state: RSState, context: [String : AnyObject]) -> RSCollectionDataSource? {
        
        guard let databaseDescriptor = RSDatabaseCollectionDataSourceDescriptor(json: dataSourceDescriptor.json),
            let dataSource = RSStateSelectors.getDataSource(state, for: databaseDescriptor.dataSourceIdentifier) else {
            return nil
        }
        
        let sortSettings = databaseDescriptor.sortSettings
        let rsPredicate = databaseDescriptor.predicate
        
        guard let predicate = RSPredicateManager.generatePredicate(predicate: rsPredicate, state: state, context: context) else {
                return nil
        }

        return dataSource.getCollectionDataSource(
            identifier: databaseDescriptor.identifier,
            predicates: [predicate],
            sortSettings: sortSettings
        )
    }
    
    public static func generateCollectionDataSource(dataSourceDescriptor: RSCollectionDataSourceDescriptor, dataSourceManager: RSCollectionDataSourceManager, state: RSState, context: [String : AnyObject], readyCallback: @escaping (RSCollectionDataSource) -> (), updateCallback: @escaping ((RSCollectionDataSource, [Int], [Int], [Int]) -> ())) -> RSCollectionDataSource? {
        guard let databaseDescriptor = RSDatabaseCollectionDataSourceDescriptor(json: dataSourceDescriptor.json),
            let dataSource = RSStateSelectors.getDataSource(state, for: databaseDescriptor.dataSourceIdentifier) else {
                return nil
        }
        
        let sortSettings = databaseDescriptor.sortSettings
        let rsPredicate = databaseDescriptor.predicate
        
        guard let predicate = RSPredicateManager.generatePredicate(predicate: rsPredicate, state: state, context: context) else {
            return nil
        }
        
        return dataSource.getCollectionDataSource(
            identifier: databaseDescriptor.identifier,
            predicates: [predicate],
            sortSettings: sortSettings,
            readyCallback: readyCallback,
            updateCallback: updateCallback
        )
    }
    

}
