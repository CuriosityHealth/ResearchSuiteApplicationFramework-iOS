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
    
    let store: Store<RSState>
    
    public init(
        initialState: RSState?,
        middleware: [Middleware]
    ) {
        
        self.store = Store<RSState>(
            reducer: RSReducer.reducer,
            state: initialState,
            middleware: middleware
        )
        
        super.init()
        
    }
    
    deinit {
        debugPrint("\(self) deiniting")
    }

}
