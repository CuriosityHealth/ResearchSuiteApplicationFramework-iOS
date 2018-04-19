//
//  RSStore.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/13/17.
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

import UIKit
import ReSwift

open class RSStore: Store<RSState> {
    
    class WeakRef {
        
        private(set) weak var value: AnyStoreSubscriber?
        
        init(value: AnyStoreSubscriber?) {
            self.value = value
        }
    }
    
    var subscribers: [WeakRef]
    
    public required convenience init(reducer: AnyReducer, state: RSState?) {
        self.init(reducer: reducer, state: state, middleware: [])
    }
    
    public required init(reducer: AnyReducer, state: State?, middleware: [Middleware]) {
        self.subscribers = []
        super.init(reducer: reducer, state: state, middleware: middleware)
    }
    
    open override func subscribe<SelectedState, S: StoreSubscriber>
        (_ subscriber: S, selector: ((State) -> SelectedState)?)
        where S.StoreSubscriberStateType == SelectedState {
            let weakRef = WeakRef(value: subscriber)
            self.subscribers.append(weakRef)
            super.subscribe(subscriber, selector: selector)
    }
    
    open func unsubscribeAll() {
        self.subscribers.forEach { (weakSubscriber) in
            if let subscriber = weakSubscriber.value {
                self.unsubscribe(subscriber)
            }
        }
    }
    
}
