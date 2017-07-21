//
//  RSStatePersistentStoreSubscriber.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit
import ReSwift
import Gloss

public class RSStatePersistentStoreSubscriber: StoreSubscriber {
    
    //note that is ok FOR NOW,
    //but this should be managed by the individual state manager
    static let kStateValueHasBeenSet: String = "StateValueHasBeenSet"
    let stateValueHasBeenSet: RSPersistedValueMap
    
    //we need to have one persistent value map for each state manager
    //and one for state value has been set metadata
    
//    public init(protectedStorageManager: RSStateManagerProtocol, unprotectedStorageManager: RSStateManagerProtocol) {
//        
//        self.protectedStorage = RSPersistedValueMap(key: RSStatePersistentStoreSubscriber.kProtectedStorage, stateManager: protectedStorageManager)
//        self.unprotectedStorage = RSPersistedValueMap(key: RSStatePersistentStoreSubscriber.kUnprotectedStorage, stateManager: unprotectedStorageManager)
//        self.stateValueHasBeenSet = RSPersistedValueMap(key: RSStatePersistentStoreSubscriber.kStateValueHasBeenSet, stateManager: unprotectedStorageManager)
//        
//    }
    
    let stateManagerMap: [String: RSPersistedValueMap]
    
    static func generateStateManager(
        stateManagerDescriptor: RSStateManagerDescriptor,
        stateManagerGenerators: [RSStateManagerGenerator.Type]
        ) -> RSStateManagerProtocol? {
        
        for generator in stateManagerGenerators {
            if generator.supportsType(type: stateManagerDescriptor.type),
                let stateManager = generator.generateStateManager(jsonObject: stateManagerDescriptor.json) {
                
                return stateManager
                
            }
        }
        
        return nil
        
    }
    
    public init(
        stateManagerDescriptors: [RSStateManagerDescriptor],
        stateManagerGenerators: [RSStateManagerGenerator.Type]
    ) {
        
        var stateManagerMap: [String: RSPersistedValueMap] = [:]
        
        stateManagerDescriptors.forEach { descriptor in
            
            if let stateManager = RSStatePersistentStoreSubscriber.generateStateManager(
                stateManagerDescriptor: descriptor,
                stateManagerGenerators: stateManagerGenerators) {
                let persistedValueMap = RSPersistedValueMap.init(key: descriptor.identifier, stateManager: stateManager)
                stateManagerMap[descriptor.identifier] = persistedValueMap
            }
        }
        
        self.stateManagerMap = stateManagerMap
        let unprotectedStorageManager =  RSFileStateManager(
            filePath: "unprotected_state",
            fileProtection: Data.WritingOptions.noFileProtection,
            decodingClasses: [NSDictionary.self, NSArray.self, NSNumber.self]
        )
        
        self.stateValueHasBeenSet = RSPersistedValueMap(key: RSStatePersistentStoreSubscriber.kStateValueHasBeenSet, stateManager: unprotectedStorageManager)
        
    }
    
    
    public func newState(state: RSState) {
        
        //need to set each stateManager
        //For each stateManager, create a map of values in the application state
        //first, get state metadata for each state manager
        //then, filter application state based on keys in state metadata
        
        let applicationState = RSStateSelectors.getApplicationState(state)
        
        for (stateManagerID, persistedValueMap) in self.stateManagerMap {
            let stateMetadata = RSStateSelectors.getStateValueMetadataForStateManager(state, stateManagerID: stateManagerID)
            let validKeys = stateMetadata.map { $0.identifier }
            var newMap: [String: NSObject] = [:]
            for (key, value) in applicationState {
                if validKeys.contains(key) { newMap[key] = value }
            }
            
            persistedValueMap.set(map: newMap)
        }
        
        self.stateValueHasBeenSet.set(map: RSStateSelectors.getStateValueHasBeenSet(state))
    }
    
    public func loadState() -> RSState {
        
        //get merge all the persisted value maps
        var mergedMap: [String: NSObject] = [:]
        
        for (_, persistedValueMap) in self.stateManagerMap {
            for (key, value) in persistedValueMap.get() {
                mergedMap[key] = value
            }
        }
        
        return RSState(
            applicationState: mergedMap,
            stateValueHasBeenSet: self.stateValueHasBeenSet.get()
        )
    }
    
    

}
