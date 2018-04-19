//
//  RSPersistedValueMap.swift
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

public class RSPersistedValueMap: NSObject {
    
    let stateManager: RSStateManagerProtocol
    
    let keyArrayKey: String
    let valueKeyComputeFunction: (String) -> (String)
    var map: [String: RSPersistedValue<NSObject>]
    var keys: RSPersistedValue<NSArray>
    
    init(key: String, stateManager: RSStateManagerProtocol) {
        self.stateManager = stateManager
        
        self.keyArrayKey = [key, "arrayKey"].joined(separator: ".")
        
        self.valueKeyComputeFunction = { valueKey in
            return [key, valueKey].joined(separator: ".")
        }
        self.keys = RSPersistedValue<NSArray>(key: self.keyArrayKey, stateManager: stateManager)
        
        if self.keys.get() == nil {
            self.keys.set(value: [String]() as NSArray)
        }
        
        self.map = [:]
        
        super.init()
        
        if let keys = self.keys.get() as? [String] {
            keys.forEach({ (key) in
                let valueKey = self.valueKeyComputeFunction(key)
                self.map[key] = RSPersistedValue<NSObject>(key: valueKey, stateManager: stateManager)
            })
        }
        
    }
    
    private subscript(key: String) -> NSObject? {
        
        get {
            
            if let persistedValue = self.map[key] {
                return persistedValue.get()
            }
            else {
                return nil
            }
        }
        
        set(newValue) {
            
            //check to see if key exists
            if let persistedValue = self.map[key] {
                
                assert(self.keys.get()!.contains(key), "PersistedValueMapError: Keys and Map Inconsistent")
                
                persistedValue.set(value: newValue)
                
                if newValue == nil {
                    persistedValue.delete()
                    self.map.removeValue(forKey: key)
                    let newKeys = (self.keys.get() as! [String]).filter({ (k) -> Bool in
                        return k != key
                    })
                    
                    self.keys.set(value: newKeys as NSArray)
                }
                
            }
            else {
                //key does not exist,
                
                if newValue != nil {
                    //add value to map
                    let newValueKey = self.valueKeyComputeFunction(key)
                    let newPersistedValue = RSPersistedValue<NSObject>(key: newValueKey, stateManager: stateManager)
                    newPersistedValue.set(value: newValue)
                    self.map[key] = newPersistedValue
                    let newKeys = (self.keys.get() as! [String]) + [key]
                    self.keys.set(value: newKeys as NSArray)
                }
            }
            
        }
    }
    
    func get() -> [String: NSObject] {
        
        
        let keys = self.keys.get() as! [String]
        var dict = [String: NSObject]()
        keys.forEach({ (key) in
            dict[key] = self.map[key]?.get()
        })
        
        return dict
    }
    
    func set(map: [String: NSObject]) {
        
        map.keys.forEach { (key) in
            self[key] = map[key]
        }
        
        //do set subtraction to potentially remove values
        let extraKeys: Set<String> = Set(self.map.keys).subtracting(Set(map.keys))
        extraKeys.forEach { (key) in
            self[key] = nil
        }
        
    }
    
    func clear() {
        self.set(map: [:])
    }

}
