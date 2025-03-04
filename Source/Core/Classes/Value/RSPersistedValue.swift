//
//  RSPersistedValue.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit

public class RSPersistedValue<T: Equatable>: RSObservableValue<T> {
    
    let key: String
    let stateManager: RSStateManagerProtocol
    
    init(key: String, stateManager: RSStateManagerProtocol) {
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
