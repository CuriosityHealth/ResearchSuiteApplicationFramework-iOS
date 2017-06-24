//
//  RSFileStateManager.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit

public class RSFileStateManager: RSStateManager {
    
    let filePath: String
    let fileProtectionType: FileProtectionType
    
    var map: [String: NSSecureCoding]
    
    let memoryQueue: DispatchQueue
    static let memoryQueueIdentifier = "RSFileStateManager.MemoryQueue"
    let fileQueue: DispatchQueue
    static let fileQueueIdentifier = "RSFileStateManager.FileQueue"
    
    init(filePath: String, fileProtectionType: FileProtectionType) {
        
        self.filePath = filePath
        self.fileProtectionType = fileProtectionType
        
        do {
            self.map = try RSFileStateManager.loadMap(filePath: filePath)
        } catch let error as NSError {
            print(error.localizedDescription)
            self.map = [:]
        }
        
        self.memoryQueue = DispatchQueue(label: RSFileStateManager.memoryQueueIdentifier)
        self.fileQueue = DispatchQueue(label: RSFileStateManager.fileQueueIdentifier)
    }
    
    private static func loadMap(filePath: String) throws -> [String: NSSecureCoding] {
        
        guard let data = FileManager.default.contents(atPath: filePath) else {
            return [:]
        }
        
        let secureUnarchiver = NSKeyedUnarchiver(forReadingWith: data)
        secureUnarchiver.requiresSecureCoding = true
        
        return secureUnarchiver.decodeObject(of: [NSArray.self], forKey: NSKeyedArchiveRootObjectKey) as? [String: NSSecureCoding] ?? [:]
        
    }
    
    private static func saveMap(map: [String: NSSecureCoding], filePath: String, fileProtectionType: FileProtectionType) throws {

        let fileURL = URL(fileURLWithPath: filePath)
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: map)
        try data.write(to: fileURL, options: Data.WritingOptions.completeFileProtectionUntilFirstUserAuthentication)
        
    }
    
    public func setValueInState(value: NSSecureCoding?, forKey: String) {
        
        self.memoryQueue.sync {
            self.map[forKey] = value
            
            self.fileQueue.async {
                do {
                    try RSFileStateManager.saveMap(map: self.map, filePath: self.filePath, fileProtectionType: self.fileProtectionType)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    public func valueInState(forKey: String) -> NSSecureCoding? {
        return self.memoryQueue.sync {
            self.map[forKey]
        }
    }
    

}
