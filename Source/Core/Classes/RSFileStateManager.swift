//
//  RSFileStateManager.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit
import Gloss
import CoreLocation

open class RSFileStateManager: RSStateManagerProtocol, RSStateManagerGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "file"
    }
    
    public static func generateStateManager(jsonObject: JSON) -> RSStateManagerProtocol? {
        
        guard let filePath: String = "filePath" <~~ jsonObject,
            let protected: Bool = "protected" <~~ jsonObject else {
                return nil
        }
        
        let decodingClasses = self.decodingClasses
        
        return RSFileStateManager(
            filePath: filePath,
            fileProtection: [protected ? Data.WritingOptions.completeFileProtectionUnlessOpen : Data.WritingOptions.noFileProtection, Data.WritingOptions.atomic],
            decodingClasses: decodingClasses
        )
        
    }
    
    open class var decodingClasses: [Swift.AnyClass] {
        return [
            NSDictionary.self,
            NSArray.self,
            NSDate.self,
            CLLocation.self,
            NSDateComponents.self,
            NSUUID.self
        ]
    }
    
    let filePath: String
    let fileProtection: NSData.WritingOptions
    
    var map: [String: NSSecureCoding]
    
    let memoryQueue: DispatchQueue
    static let memoryQueueIdentifier = "RSFileStateManager.MemoryQueue"
    let fileQueue: DispatchQueue
    static let fileQueueIdentifier = "RSFileStateManager.FileQueue"
    
    init(filePath: String, fileProtection: Data.WritingOptions, decodingClasses: [Swift.AnyClass]) {
        
        self.filePath = RSFileStateManager.generateFilePath(filePath: filePath)!
        print(self.filePath)
        
        self.fileProtection = fileProtection
    
        do {
            self.map = try RSFileStateManager.loadMap(filePath: filePath, decodingClasses: decodingClasses)
        } catch let error as NSError {
            print(error.localizedDescription)
            self.map = [:]
        }
        
        self.memoryQueue = DispatchQueue(label: RSFileStateManager.memoryQueueIdentifier)
        self.fileQueue = DispatchQueue(label: RSFileStateManager.fileQueueIdentifier)
    }
    
    private static func generateFilePath(filePath: String) -> String? {
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            return nil
        }
        
        return documentsPath.appending("/\(filePath)")
    }
    
    private static func loadMap(filePath: String, decodingClasses: [Swift.AnyClass]) throws -> [String: NSSecureCoding] {
        
        guard let fullFilePath = RSFileStateManager.generateFilePath(filePath: filePath),
            let data = FileManager.default.contents(atPath: fullFilePath) else {
            return [:]
        }
        
        let secureUnarchiver = NSKeyedUnarchiver(forReadingWith: data)
        secureUnarchiver.requiresSecureCoding = true
        
        return secureUnarchiver.decodeObject(of: decodingClasses, forKey: NSKeyedArchiveRootObjectKey) as? [String: NSSecureCoding] ?? [:]
        
    }
    
    private static func saveMap(map: [String: NSSecureCoding], filePath: String, fileProtection: NSData.WritingOptions) throws {

        let fileURL = URL(fileURLWithPath: filePath)
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: map)
        try data.write(to: fileURL, options: fileProtection)
        
    }
    
    public func setValueInState(value: NSSecureCoding?, forKey: String) {
        
        self.memoryQueue.sync {
            self.map[forKey] = value
            
            let map = self.map
            
            self.fileQueue.async {
                do {
                    try RSFileStateManager.saveMap(map: map, filePath: self.filePath, fileProtection: self.fileProtection)
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
