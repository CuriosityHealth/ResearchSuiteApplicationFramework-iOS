//
//  RSCollectionDataSourceManager.swift
//  Pods
//
//  Created by James Kizer on 5/28/18.
//

import UIKit

open class RSCollectionDataSourceManager: NSObject {
    
    let collectionDataSourceGenerators: [RSCollectionDataSourceGenerator.Type]
    
    public init(
        collectionDataSourceGenerators: [RSCollectionDataSourceGenerator.Type]?
        ) {
        self.collectionDataSourceGenerators = collectionDataSourceGenerators ?? []
        super.init()
    }
    
    open func generateCollectionDataSource(
        dataSourceDescriptor: RSCollectionDataSourceDescriptor,
        state: RSState,
        context: [String : AnyObject]
        ) -> RSCollectionDataSource? {

        guard let transformer = self.collectionDataSourceGenerators.first(where: { $0.supportsType(type: dataSourceDescriptor.type) } ) else {
            return nil
        }
        
        return transformer.generateCollectionDataSource(
            dataSourceDescriptor: dataSourceDescriptor,
            dataSourceManager: self,
            state: state,
            context: context
        )
        
    }
    
    open func generateCollectionDataSource(
        dataSourceDescriptor: RSCollectionDataSourceDescriptor,
        state: RSState,
        context: [String : AnyObject],
        readyCallback: @escaping (RSCollectionDataSource)->(),
        updateCallback: @escaping ((RSCollectionDataSource, [Int], [Int], [Int]) -> ())) -> RSCollectionDataSource? {
        
        guard let transformer = self.collectionDataSourceGenerators.first(where: { $0.supportsType(type: dataSourceDescriptor.type) } ) else {
            return nil
        }
        
        return transformer.generateCollectionDataSource(
            dataSourceDescriptor: dataSourceDescriptor,
            dataSourceManager: self,
            state: state,
            context: context,
            readyCallback: readyCallback,
            updateCallback: updateCallback
        )
        
    }

}
