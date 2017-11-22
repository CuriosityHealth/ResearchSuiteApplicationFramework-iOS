//
//  RSLoggingMiddleware.swift
//  Pods
//
//  Created by James Kizer on 7/20/17.
//
//

import ReSwift
import ResearchSuiteResultsProcessor

open class RSLoggingMiddleware: RSMiddlewareProvider {
    
    open static func getMiddleware(appDelegate: RSApplicationDelegate) -> Middleware? {
        return { dispatch, getState in
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
                    
                    weak var store = RSApplicationDelegate.appDelegate.store
                    print("store ref count: \(CFGetRetainCount(store))")
                    
                    // call next middleware
                    return retVal
                }
            }
        }
    }
}

