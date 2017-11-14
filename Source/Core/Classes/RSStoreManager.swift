//
//  RSStoreManager.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ReSwift

public class RSStoreManager: NSObject {
    
    let store: RSStore
    
    public init(
        initialState: RSState?,
        middleware: [Middleware]
    ) {
        
        self.store = RSStore(
            reducer: RSReducer.reducer,
            state: initialState,
            middleware: middleware
        )
        
        super.init()
        
    }
    
    deinit {
        debugPrint("\(self) deiniting")
    }
    
    public func unsubscribeAll() {
        self.store.unsubscribeAll()
    }

}
