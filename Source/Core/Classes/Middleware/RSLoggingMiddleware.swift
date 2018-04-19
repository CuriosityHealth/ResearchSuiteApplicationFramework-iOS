//
//  RSLoggingMiddleware.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/20/17.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
                    
                    weak var store = RSApplicationDelegate.appDelegate.store
                    print("store ref count: \(CFGetRetainCount(store))")
                    
                    // call next middleware
                    return retVal
                }
            }
        }
    }
}

