//
//  RSStore.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/13/17.
//

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
