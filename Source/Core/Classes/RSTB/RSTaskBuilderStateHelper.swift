//
//  RSTaskBuilderStateHelper.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import ResearchSuiteTaskBuilder

public class RSTaskBuilderStateHelper: NSObject, RSTBStateHelper, StoreSubscriber  {
    
    var state: RSState!
    weak var store: Store<RSState>?
    
    public init(store: Store<RSState>) {
        self.store = store
        super.init()
        self.store?.subscribe(self)
    }
    
    open func newState(state: RSState) {
        self.state = state
    }
    
    open func setValueInState(value: NSSecureCoding?, forKey: String) {
        self.store?.dispatch(RSActionCreators.setValueInState(key: forKey, value: value != nil ? value! as? NSObject : nil))
    }
    
    //TDOD: this should probably throw in the future
    open func valueInState(forKey: String) -> NSSecureCoding? {
        return RSStateSelectors.getValueInCombinedState(self.state, for: forKey) as? NSSecureCoding
    }
    
    deinit {
        self.store?.unsubscribe(self)
    }
    
}
