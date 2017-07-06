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

    var valueSelector: ((String) -> ValueConvertible?)?
    var constantsSelector: ((String) -> ValueConvertible?)?
    var functionSelector: ((String) -> ValueConvertible?)?
    
    let store: Store<RSState>
    
    public init(store: Store<RSState>) {
        self.store = store
        super.init()
        self.store.subscribe(self)
    }
    
    open func newState(state: RSState) {
        self.valueSelector = { key in
            return RSStateSelectors.getValueInStorage(state, for: key)
        }
        
        self.constantsSelector = { key in
            return RSStateSelectors.getConstantValue(state, for: key)
        }
        
        self.functionSelector = { key in
            return RSStateSelectors.getFunctionValue(state, for: key)
        }
    }
    
    open func setValueInState(value: NSSecureCoding?, forKey: String) {
        self.store.dispatch(RSActionCreators.setValueInState(key: forKey, value: value != nil ? value! as? NSObject : nil))
    }
    
    //TDOD: this should probably throw in the future
    
    open func valueInState(forKey: String) -> NSSecureCoding? {
        
        if let valueConvertible: ValueConvertible = self.valueSelector?(forKey) {
            return valueConvertible.evaluate() as? NSSecureCoding
        }
        else if let valueConvertible: ValueConvertible = self.constantsSelector?(forKey) {
            return valueConvertible.evaluate() as? NSSecureCoding
        }
        else if let valueConvertible: ValueConvertible = self.functionSelector?(forKey) {
            return valueConvertible.evaluate() as? NSSecureCoding
        }
        
        return nil
    }
    
    deinit {
        debugPrint("\(self) deiniting")
        self.store.unsubscribe(self)
    }
    
}
