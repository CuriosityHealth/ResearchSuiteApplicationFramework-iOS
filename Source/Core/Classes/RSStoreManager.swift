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
    
    public init(initialState: RSState?) {
        
        let loggingMiddleware: Middleware = { dispatch, getState in
            return { next in
                return { action in
                    // perform middleware logic
                    let oldState: RSState? = getState() as? RSState
                    let retVal = next(action)
                    let newState: RSState? = getState() as? RSState
                    
                    print("\n")
                    print("*******************************************************")
                    if let oldState = oldState {
                        print("oldState: \(oldState)")
                    }
                    print("action: \(action)")
                    if let newState = newState {
                        print("newState: \(newState)")
                    }
                    print("*******************************************************\n")
                    
                    // call next middleware
                    return retVal
                }
            }
        }
        
        self.store = Store<RSState>(
            reducer: RSReducer.reducer,
            state: initialState,
            middleware: [
                loggingMiddleware,
                RSSendResultToServerMiddleware.sendResultToServerMidleware()
            ]
        )
        
        super.init()
        
    }
    
    deinit {
        debugPrint("\(self) deiniting")
    }

}
