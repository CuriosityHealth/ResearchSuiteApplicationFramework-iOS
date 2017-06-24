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
    
    let protectedStorage: RSPersistedValueMap
    let unprotectedStorage: RSPersistedValueMap
    
    public init(protectedStorageManager: RSStateManager, unprotectedStorageManager: RSStateManager) {
        
        self.protectedStorage = RSPersistedValueMap(key: RSStatePersistentStoreSubscriber.kProtectedStorage, stateManager: protectedStorageManager)
        self.unprotectedStorage = RSPersistedValueMap(key: RSStatePersistentStoreSubscriber.kUnprotectedStorage, stateManager: unprotectedStorageManager)
        
    }
    
    
    public func newState(state: RSState) {
        
        self.protectedStorage.set(map: RSStateSelectors.getProtectedStorage(state))
        self.unprotectedStorage.set(map: RSStateSelectors.getUnprotectedStorage(state))
        
    }
    
    public func loadState() -> RSState {
        return RSState(
            protectedState: self.protectedStorage.get(),
            unprotectedState: self.unprotectedStorage.get()
        )
    }
    
    

}
