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
    static let kStateValueHasBeenSet: String = "RSStatePersistentStoreSubscriber.StateValueHasBeenSet"
    let stateValueHasBeenSet: RSPersistedValueMap
    let stateValueHasBeenSetStorageManager: RSFileStateManager
    
    
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
    let stateManagers: [RSStateManagerProtocol]
    
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
        var stateManagers: [RSStateManagerProtocol] = []
        
        stateManagerDescriptors.forEach { descriptor in
            
            if let stateManager = RSStatePersistentStoreSubscriber.generateStateManager(
                stateManagerDescriptor: descriptor,
                stateManagerGenerators: stateManagerGenerators) {
                stateManagers.append(stateManager)
                let persistedValueMap = RSPersistedValueMap.init(key: descriptor.identifier, stateManager: stateManager)
                stateManagerMap[descriptor.identifier] = persistedValueMap
            }
        }
        
        self.stateManagerMap = stateManagerMap
        self.stateManagers = stateManagers
        self.stateValueHasBeenSetStorageManager =  RSFileStateManager(
            identifier: "RSStatePersistentStoreSubscriber",
            filePath: RSStatePersistentStoreSubscriber.kStateValueHasBeenSet,
            fileProtection: Data.WritingOptions.noFileProtection,
            decodingClasses: [NSDictionary.self, NSArray.self, NSNumber.self]
        )
        
        self.stateValueHasBeenSet = RSPersistedValueMap(key: RSStatePersistentStoreSubscriber.kStateValueHasBeenSet, stateManager: self.stateValueHasBeenSetStorageManager)
        
    }
    
    private func stateManagerForStateValue(identifier: String, state: RSState) -> RSStateManagerProtocol? {
        guard let stateValue = RSStateSelectors.getStateValueMetadata(state, for: identifier) else {
            return nil
        }
        
        return self.stateManagers.first(where: { $0.identifier == stateValue.stateManager})
    }
    
    public func newState(state: RSState) {
        
        //we need to prevent writing to the persistent maps before the application has 
        //configured the state metadata
        //if there is no state metadata, then we would end up removing everything from the persistent
        //store and get in a weird state
        
        guard RSStateSelectors.isConfigurationCompleted(state) else {
            return
        }

        //need to set each stateManager
        //For each stateManager, create a map of values in the application state
        //first, get state metadata for each state manager
        //then, filter application state based on keys in state metadata
        
        let applicationState = RSStateSelectors.getApplicationState(state)
        
        for (stateManagerID, persistedValueMap) in self.stateManagerMap {
            let stateMetadata = RSStateSelectors.getStateValueMetadataForStateManager(state, stateManagerID: stateManagerID)
            //We need to prevent
            assert(stateMetadata.count > 0, "Attempting to set persistent store with no state metadata. THIS WILL CLEAR THE STORE!!!")
            let validKeys = stateMetadata.map { $0.identifier }
            var newMap: [String: NSObject] = [:]
            for (key, value) in applicationState {
                if validKeys.contains(key) { newMap[key] = value }
            }
            
            persistedValueMap.set(map: newMap)
        }
        
        //filter these based on whether the state manager is ephemeral
        //only persist value has been set metadata across app launches if the state manager is NOT ephemeral
        //ephemeral states expect that values clear and that the value has not been set at app launch
        //note that this should not affect t
        let stateValueHasBeenSetMap = RSStateSelectors.getStateValueHasBeenSet(state)
        var filteredStateValueHasBeenSetMap: [String: NSObject] = [:]
        for (stateValueIdentifier, hasBenSet) in stateValueHasBeenSetMap {
            if let stateManager = self.stateManagerForStateValue(identifier: stateValueIdentifier, state: state),
                stateManager.isEphemeral == false {
                filteredStateValueHasBeenSetMap[stateValueIdentifier] = hasBenSet
            }
        }
        
        self.stateValueHasBeenSet.set(map: filteredStateValueHasBeenSetMap)
    }
    
    public func loadState() -> RSState {
        
        //get merge all the persisted value maps
        var mergedMap: [String: NSObject] = [:]
        
        for (_, persistedValueMap) in self.stateManagerMap {
            let persistedValues = persistedValueMap.get()
            for (key, value) in persistedValues {
                mergedMap[key] = value
            }
        }
        
        return RSState(
            applicationState: mergedMap,
            stateValueHasBeenSet: self.stateValueHasBeenSet.get()
        )
    }
    
    public func clearState(completion: @escaping (Bool, Error?) -> ()) {
        
        self.stateManagerMap.values.forEach { $0.clear() }
        self.stateValueHasBeenSet.clear()

        let nestedClosure: (Bool, Error?) -> () = self.stateManagers.reduce(completion) { (accCompletion, stateManager) -> ((Bool, Error?) -> ()) in
            return { (completed, error) in
                stateManager.clearStateManager(completion: accCompletion)
            }
        }
        
        self.stateValueHasBeenSetStorageManager.clearStateManager(completion: nestedClosure)

    }
    
    

}
