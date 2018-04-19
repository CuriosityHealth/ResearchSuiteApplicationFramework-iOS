//
//  RSPersistedValue.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
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
