//
//  RSCompositeCollectionDataSource.swift
//  Pods
//
//  Created by James Kizer on 5/26/18.
//

import UIKit
//import Realm
import LS2SDK

open class RSCompositeCollectionDataSource: RSCollectionDataSource, RSCollectionDataSourceGenerator {
    
    
    public static func supportsType(type: String) -> Bool {
        return type == "composite"
    }
    
    public static func generateCollectionDataSource(
        dataSourceDescriptor: RSCollectionDataSourceDescriptor,
        dataSourceManager: RSCollectionDataSourceManager,
        state: RSState,
        context: [String : AnyObject]) -> RSCollectionDataSource? {
        
        guard let compositeDescriptor = RSCompositeCollectionDataSourceDescriptor(json: dataSourceDescriptor.json) else {
            return nil
        }
        
        return RSCompositeCollectionDataSource(
            identifier: compositeDescriptor.identifier,
            childDataSourceDescriptors: compositeDescriptor.childDescriptors,
            dataSourceManager: dataSourceManager,
            state: state,
            context: context,
            readyCallback: nil,
            updateCallback: nil
        )
        
    }
    
    public static func generateCollectionDataSource(
        dataSourceDescriptor: RSCollectionDataSourceDescriptor,
        dataSourceManager: RSCollectionDataSourceManager,
        state: RSState,
        context: [String : AnyObject],
        readyCallback: @escaping (RSCollectionDataSource) -> (),
        updateCallback: @escaping ((RSCollectionDataSource, [Int], [Int], [Int]) -> ())) -> RSCollectionDataSource? {
        
        
        guard let compositeDescriptor = RSCompositeCollectionDataSourceDescriptor(json: dataSourceDescriptor.json) else {
            return nil
        }

        return RSCompositeCollectionDataSource(
            identifier: compositeDescriptor.identifier,
            childDataSourceDescriptors: compositeDescriptor.childDescriptors,
            dataSourceManager: dataSourceManager,
            state: state,
            context: context,
            readyCallback: readyCallback,
            updateCallback: updateCallback
        )
        
    }
    
    open let identifier: String
    //
    var collectionDataSources: [RSCollectionDataSource]
//    var collectionDataSourceMap: [String: RSCollectionDataSource]
    
    //each data source
    
    //ready callback needs to wait until all are ready
//    var readyCallbackQueue: DispatchQueue
    var ready: [String: Bool]
    //once ready, dump everything into an array, apply sort
//    var datapoints: [((String, Int), LS2Datapoint)]?
    
    
    //
    var resultPaths: [IndexPath]?
    var memoizedResults: [LS2Datapoint]?
    var resultDatapoints: [Int: [LS2Datapoint]]?
    
    //update callback propagates all updates from child data sources to caller
    
    public init?(
        identifier: String,
        childDataSourceDescriptors: [RSCollectionDataSourceDescriptor],
        dataSourceManager: RSCollectionDataSourceManager,
        state: RSState,
        context: [String: AnyObject],
        readyCallback: ((RSCollectionDataSource)->())?,
        updateCallback: (((RSCollectionDataSource, [Int], [Int], [Int]) -> ()))?) {
        
        let readyCallbackQueue = DispatchQueue(label: UUID().uuidString)
        
        let compositeReadyCallback = readyCallback
        let compositeUpdateCallback = updateCallback
        
        self.identifier = identifier
        self.ready = [:]
        self.collectionDataSources = []
        
        readyCallbackQueue.suspend()
        
        let collectionReadyCallback: (RSCollectionDataSource)->() = { [unowned self] collectionDataSource in
            
            let allReady: Bool = readyCallbackQueue.sync(execute: { () -> Bool in
                
                //first mark this data source as ready
                let collectionIdentifier = collectionDataSource.identifier
                assert(self.ready[collectionIdentifier]! == false)
                self.ready[collectionIdentifier] = true
                
                //next, return true if all are ready
                //returns true if all values in ready map are true
                return self.ready.values.reduce(true, { (acc, ready) -> Bool in
                    return acc && ready
                })
                
            })
            
            if allReady {
                
                self.initializeResults()
                compositeReadyCallback?(self)
            }
            
        }
        
        let collectionUpdateCallback: (RSCollectionDataSource, [Int], [Int], [Int]) -> () = { [unowned self] collectionDataSource, deletions, insertions, modifications in
            
            let allReady: Bool = readyCallbackQueue.sync(execute: { () -> Bool in
                //next, return true if all are ready
                //returns true if all values in ready map are true
                return self.ready.values.reduce(true, { (acc, ready) -> Bool in
                    return acc && ready
                })
            })
            
            if allReady {
                if let updates = self.updateResults(collectionDataSource: collectionDataSource, deletions: deletions, insertions: insertions, modifications: modifications) {
                    compositeUpdateCallback?(self, updates.0, updates.1, updates.2)
                }
                
            }
            
        }
        
        
        
        let dataSources: [RSCollectionDataSource] = childDataSourceDescriptors.compactMap { (dataSourceDescriptor) -> RSCollectionDataSource? in
            
            return dataSourceManager.generateCollectionDataSource(
                dataSourceDescriptor: dataSourceDescriptor,
                state: state,
                context: context,
                readyCallback: collectionReadyCallback,
                updateCallback: collectionUpdateCallback
            )
            
        }
        
        self.ready = Dictionary.init(uniqueKeysWithValues: dataSources.map { ($0.identifier, false) })
        readyCallbackQueue.resume()
        
        self.collectionDataSources = dataSources
 
    }
    
    func initializeResults() {
        
        let pairs: [(Int, [LS2Datapoint])] = self.collectionDataSources.enumerated().map { (offset, collectionDataSource) -> (Int, [LS2Datapoint]) in
            
            let collectionArray: [LS2Datapoint] =  collectionDataSource.toArray() ?? []
            return (offset, collectionArray)
            
        }

        self.resultDatapoints = Dictionary.init(uniqueKeysWithValues: pairs)
        
        self.resultPaths = pairs.flatMap({ (pair) -> [IndexPath] in
            let length = pair.1.count
            return (0..<length).map { IndexPath(row: $0, section: pair.0) }
        })
        
    }
    
    func updateResults(collectionDataSource: RSCollectionDataSource, deletions: [Int], insertions: [Int], modifications: [Int]) -> ([Int], [Int], [Int])? {

        //first based on deletions remove from resultPaths, memoized datapoints, and resultDatapoints
        self.memoizedResults = nil
        
        let dataSourceIndex: Int = self.collectionDataSources.index { (dataSource) -> Bool in
            return collectionDataSource.identifier == dataSource.identifier
        }!
        
        guard var resultDatapoints = self.resultDatapoints,
            let resultDatapointsForDataSource = resultDatapoints[dataSourceIndex],
            let oldResultPaths = self.resultPaths else {
                return nil
        }
        
        let compositeDeletions: [Int] = deletions.compactMap { index in
            let indexPath = IndexPath(row: index, section: dataSourceIndex)
            return oldResultPaths.index(of: indexPath)
        }
        
        guard let array = collectionDataSource.toArray() else {
            return nil
        }
        
        resultDatapoints[dataSourceIndex] = array
        self.resultDatapoints = resultDatapoints
            
        let newResultPaths = resultDatapoints.flatMap({ (pair) -> [IndexPath] in
            let length = pair.1.count
            return (0..<length).map { IndexPath(row: $0, section: pair.0) }
        })
        
        self.resultPaths = newResultPaths
        
        let compositeInsertions: [Int] = insertions.compactMap { index in
            let indexPath = IndexPath(row: index, section: dataSourceIndex)
            return newResultPaths.index(of: indexPath)
        }
        
        let compositeModifications: [Int] = modifications.compactMap { index in
            let indexPath = IndexPath(row: index, section: dataSourceIndex)
            return newResultPaths.index(of: indexPath)
        }
        
        return (compositeDeletions, compositeInsertions, compositeModifications)
        
//        let dataSourceIndex: Int = self.collectionDataSources.index { (dataSource) -> Bool in
//            return collectionDataSource.identifier == dataSource.identifier
//        }!
////
//        guard let resultDatapoints = self.resultDatapoints,
//            let resultDatapointsForDataSource = resultDatapoints[dataSourceIndex],
//            let resultPaths = self.resultPaths else {
//            return
//        }
//
//        let deletionsSet = Set(deletions)
//
////        let datapointsToRemove: [LS2Datapoint] = deletions.compactMap { index in
////            return resultDatapointsForDataSource[index]
////        }
//
//        let indexPathsToRemove: Set<IndexPath> = Set(deletions.compactMap { index in
//            return IndexPath(row: index, section: dataSourceIndex)
//        })
//
//        let resultPathsAfterRemoval: [IndexPath] = resultPaths.filter { indexPathsToRemove.contains($0) }
//        let resultDatapointsAfterDeletion:[LS2Datapoint] = resultDatapointsForDataSource.enumerated().filter { (offset, element) -> Bool in
//            return !deletionsSet.contains(offset)
//        }
//            .map {  $0.element }
//
//        //inserts
        
        
        
        
    }
    
    public var count: Int? {
        return self.toArray()?.count
    }
    
    //need constant time lookup
    public func get(for index: Int) -> LS2Datapoint? {

        guard let results = self.toArray(),
            index < results.count else {
                assertionFailure("Shouldnt happen!!")
                return nil
        }
        
        return results[index]
    }
    
    public func generateDictionary() -> [Int : LS2Datapoint]? {
        
        guard let results = self.toArray() else {
                return nil
        }
        
        return Dictionary.init(uniqueKeysWithValues: results.enumerated().map { ($0.offset, $0.element) } )

    }
    
    public func toArray() -> [LS2Datapoint]? {
        
        if let memoizedResults = self.memoizedResults {
            return memoizedResults
        }
        else {
            
            guard let resultDatapoints = self.resultDatapoints else {
                return nil
            }
            
            let memoizedResults = self.resultPaths?.compactMap({ (indexPath) -> LS2Datapoint? in
                let collectionArray = resultDatapoints[indexPath.section]!
                return collectionArray[indexPath.row]
            })
            
            self.memoizedResults = memoizedResults
            return memoizedResults
        }
    }
    
    open func dataSource(for index: Int) -> RSCollectionDataSource? {
        guard let path = self.resultPaths?[index] else {
            return nil
        }
        
        return self.collectionDataSources[path.section]
    }

}
