//
//  RSStatePersistentStoreSubscriber.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit
import ReSwift

public class RSStatePersistentStoreSubscriber: StoreSubscriber {
    
    static let kProtectedStorage: String = "ProtectedStorage"
    static let kUnprotectedStorage: String = "UnprotectedStorage"
    static let kStateValueHasBeenSet: String = "StateValueHasBeenSet"
    
    let protectedStorage: RSPersistedValueMap
    let unprotectedStorage: RSPersistedValueMap
    let stateValueHasBeenSet: RSPersistedValueMap
    
    public init(protectedStorageManager: RSStateManager, unprotectedStorageManager: RSStateManager) {
        
        self.protectedStorage = RSPersistedValueMap(key: RSStatePersistentStoreSubscriber.kProtectedStorage, stateManager: protectedStorageManager)
        self.unprotectedStorage = RSPersistedValueMap(key: RSStatePersistentStoreSubscriber.kUnprotectedStorage, stateManager: unprotectedStorageManager)
        self.stateValueHasBeenSet = RSPersistedValueMap(key: RSStatePersistentStoreSubscriber.kStateValueHasBeenSet, stateManager: unprotectedStorageManager)
        
    }
    
    
    public func newState(state: RSState) {
        
        self.protectedStorage.set(map: RSStateSelectors.getProtectedStorage(state))
        self.unprotectedStorage.set(map: RSStateSelectors.getUnprotectedStorage(state))
        self.stateValueHasBeenSet.set(map: RSStateSelectors.getStateValueHasBeenSet(state))
        
    }
    
    public func loadState() -> RSState {
        return RSState(
            protectedState: self.protectedStorage.get(),
            unprotectedState: self.unprotectedStorage.get(),
            stateValueHasBeenSet: self.stateValueHasBeenSet.get()
        )
    }
    
    

}
