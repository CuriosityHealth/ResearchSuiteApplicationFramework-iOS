//
//  RSStoreManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
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
    
    public func unsubscribeAll() {
        self.store.unsubscribeAll()
    }

}
