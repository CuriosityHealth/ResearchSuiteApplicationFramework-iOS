//
//  RSTaskBuilderStateHelper.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
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
        debugPrint("\(self) deiniting")
        self.store?.unsubscribe(self)
    }
    
}
