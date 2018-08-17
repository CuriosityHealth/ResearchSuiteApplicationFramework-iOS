//
//  RSLoggingMiddleware.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/20/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import ReSwift
import ResearchSuiteResultsProcessor

open class RSLoggingMiddleware: RSMiddlewareProvider {
    
    static var dispatchCount = 0
    static var totalDispatchTime: TimeInterval = 0
    static var maxDispatchTime: TimeInterval = 0
    static var maxDispatchAction: Action?
    
    open static func getMiddleware(appDelegate: RSApplicationDelegate) -> Middleware? {
        return { dispatch, getState in
            return { next in
                return { action in
                    // perform middleware logic
                    let oldState: RSState? = getState() as? RSState
                    let startTime = Date()
                    let retVal = next(action)
                    let endTime = Date()
                    let interval = endTime.timeIntervalSince(startTime)
                    if interval > maxDispatchTime {
                        maxDispatchTime = interval
                        maxDispatchAction = action
                    }
                    totalDispatchTime = totalDispatchTime + interval
                    dispatchCount = dispatchCount + 1
                    let newState: RSState? = getState() as? RSState
                    
                    print("\n")
                    print("*******************************************************")
                    if let oldState = oldState {
                        print("oldState: \(oldState)")
                    }
                    print("action: \(action)")
                    print("dispatch took \(endTime.timeIntervalSince(startTime)) seconds")
                    
                    print("num dispatchs \(dispatchCount)")
                    print("total dispatch \(totalDispatchTime) seconds")
                    print("avg dispatch \(totalDispatchTime / Double(dispatchCount)) seconds")
                    print("max dispatch \(maxDispatchTime) seconds")
                    
                    if let newState = newState {
                        print("newState: \(newState)")
                    }
                    print("*******************************************************\n")
                    
                    if var store = RSApplicationDelegate.appDelegate.store {
                        print("store ref count: \(CFGetRetainCount(store))")
                    }
                    
                    // call next middleware
                    return retVal
                }
            }
        }
    }
}

