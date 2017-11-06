//
//  RSTaskBuilderStateHelper.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ReSwift
import ResearchSuiteTaskBuilder

public class RSTaskBuilderStateHelper: NSObject, RSTBStateHelper, StoreSubscriber  {
    
    var state: RSState!
    let store: Store<RSState>
    
    public init(store: Store<RSState>) {
        self.store = store
        super.init()
        self.store.subscribe(self)
    }
    
    open func newState(state: RSState) {
        self.state = state
    }
    
    open func setValueInState(value: NSSecureCoding?, forKey: String) {
        self.store.dispatch(RSActionCreators.setValueInState(key: forKey, value: value != nil ? value! as? NSObject : nil))
    }
    
    //TDOD: this should probably throw in the future
    open func valueInState(forKey: String) -> NSSecureCoding? {
        return RSStateSelectors.getValueInCombinedState(self.state, for: forKey) as? NSSecureCoding
    }
    
    deinit {
        debugPrint("\(self) deiniting")
        self.store.unsubscribe(self)
    }
    
}
