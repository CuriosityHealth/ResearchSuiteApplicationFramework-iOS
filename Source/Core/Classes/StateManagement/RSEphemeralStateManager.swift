//
//  RSEphemeralStateManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/11/17.
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
import Gloss

open class RSEphemeralStateManager: RSStateManagerProtocol, RSStateManagerGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "ephemeral"
    }
    
    public static func generateStateManager(jsonObject: JSON) -> RSStateManagerProtocol? {
        
        guard let identifier: String = "identifier" <~~ jsonObject else {
                return nil
        }

        return RSEphemeralStateManager(identifier: identifier)
        
    }
    
    public var isEphemeral: Bool {
        return true
    }
    
    public let identifier: String
    var map: [String: NSSecureCoding]
    let memoryQueue: DispatchQueue
    static let memoryQueueIdentifier: (String) -> String = { identifier in
        "RSEphemeralStateManager.\(identifier).MemoryQueue"
    }
    
    init(identifier: String) {
        self.identifier = identifier
        self.memoryQueue = DispatchQueue(label: RSEphemeralStateManager.memoryQueueIdentifier(identifier))
        self.map = [:]
    }
    
    public func setValueInState(value: NSSecureCoding?, forKey: String) {
        self.memoryQueue.sync {
            self.map[forKey] = value
        }
    }
    
    public func valueInState(forKey: String) -> NSSecureCoding? {
        return self.memoryQueue.sync {
            self.map[forKey]
        }
    }
    
    public func clearStateManager(completion: @escaping (Bool, Error?) -> ()) {
        self.memoryQueue.sync {
            self.map = [:]
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
    }
    
    
}
