//
//  RSEphemeralStateManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/11/17.
//

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
    
    let identifier: String
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
