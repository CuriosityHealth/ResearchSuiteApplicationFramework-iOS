//
//  RSPersistedValue.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit

public class RSPersistedValue<T: Equatable>: RSObservableValue<T> {
    
    let key: String
    let stateManager: RSStateManager
    
    init(key: String, stateManager: RSStateManager) {
        self.key = key
        self.stateManager = stateManager
        
        let observationClosure: ObservationClosure = { value in
            let secureCodingValue = value as? NSSecureCoding
            stateManager.setValueInState(value: secureCodingValue, forKey: key)
        }
        
        super.init(
            initialValue: stateManager.valueInState(forKey: key) as? T,
            observationClosure: observationClosure
        )
        
    }
    
    func delete() {
        stateManager.setValueInState(value: nil, forKey: self.key)
    }

}
