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
    let extraStateValues: [String: AnyObject]
    
    public init(store: Store<RSState>, extraStateValues: [String: AnyObject]) {
        self.store = store
        self.extraStateValues = extraStateValues
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
        
        if let value = self.extraStateValues[forKey] as? NSSecureCoding {
            return value
        }
        
        return RSStateSelectors.getValueInCombinedState(self.state, for: forKey) as? NSSecureCoding
    }
    
    public func objectInState(forKey: String) -> AnyObject? {
        
        if let value = self.extraStateValues[forKey] {
            return value
        }
        
        return RSStateSelectors.getValueInCombinedState(self.state, for: forKey)
    }
    
    deinit {
        self.store?.unsubscribe(self)
    }
    
}
