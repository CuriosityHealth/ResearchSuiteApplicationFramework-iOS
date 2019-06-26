//
//  RSFileStorage.swift
//  Pods
//
//  Created by James Kizer on 6/3/19.
//

import UIKit
import ResearchSuiteExtensions

open class RSFileStorage: NSObject {
    
    public let storageDirectory: URL
    let storageDirectoryFileProtection: FileProtectionType
    
    static var TAG = "RSFileStorage"
    let logger: RSLogger?
    
    public init?(
        storageDirectory: String,
        storageDirectoryFileProtection: FileProtectionType,
        logger: RSLogger? = nil
        ) {
        
        guard let storageDirectoryURL = RSFileStorage.setupStorageDirectory(storageDirectory: storageDirectory, storageDirectoryFileProtection: storageDirectoryFileProtection, logger: logger) else {
            return nil
        }
        
        self.storageDirectory = storageDirectoryURL
        self.storageDirectoryFileProtection = storageDirectoryFileProtection
        
        self.logger = logger
        
        super.init()
        
        self.testStorageSettings()
    }
    
    open func isURLRelativeToStorageDirectory(url: URL) -> Bool {
        return self.storageDirectory.path.prefix(self.storageDirectory.path.count) == url.path.prefix(self.storageDirectory.path.count)
    }
    
    open func getRelativePathToStorageDirectory(url: URL) -> String? {
        if self.isURLRelativeToStorageDirectory(url: url) {
            return String(url.path.dropFirst(self.storageDirectory.path.count))
        }
        else {
            assertionFailure()
            return nil
        }
    }
    
    open func urlRelativeToStorageDirectory(path: String) -> URL {
        return self.storageDirectory.appendingPathComponent(path)
    }
    
    open func delete(completion: @escaping ((Error?) -> ())) {
        
        do {
            try FileManager.default.removeItem(at: self.storageDirectory)
            completion(nil)
        } catch let error as NSError {
            logger?.log(tag: RSFileStorage.TAG, level: .error, message: "An error occurred removing the directory: \(error)")
            completion(error)
        }
        
    }
    
    static func setupStorageDirectory(storageDirectory: String, storageDirectoryFileProtection: FileProtectionType, logger: RSLogger?) -> URL? {
        
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            logger?.log(tag: RSFileStorage.TAG, level: .warn, message: "storage failed initialization")
            return nil
        }
        
        let finalStorageDirectory = documentsPath.appending("/\(storageDirectory)")
        var isDirectory : ObjCBool = false
        if FileManager.default.fileExists(atPath: finalStorageDirectory, isDirectory: &isDirectory) {
            
            //if a file, remove file and add directory
            if isDirectory.boolValue {
                
            }
            else {
                logger?.log(tag: RSFileStorage.TAG, level: .warn, message: "File found at storage directory. Removing...")
                do {
                    try FileManager.default.removeItem(atPath: finalStorageDirectory)
                } catch let error as NSError {
                    //TODO: handle this
                    logger?.log(tag: RSFileStorage.TAG, level: .error, message: "An error occurred removing the file: \(error)")
                    //                    print(error.localizedDescription);
                }
            }
            
        }
        
        do {
            logger?.log(tag: RSFileStorage.TAG, level: .info, message: "Configuring storage directory: \(finalStorageDirectory)")
            try FileManager.default.createDirectory(atPath: finalStorageDirectory, withIntermediateDirectories: true, attributes: [.protectionKey: storageDirectoryFileProtection])
            var url: URL = URL(fileURLWithPath: finalStorageDirectory)
            var resourceValues: URLResourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try url.setResourceValues(resourceValues)
            return url
            
        } catch let error as NSError {
            logger?.log(tag: RSFileStorage.TAG, level: .error, message: "An error occurred configuring the storage directory: \(error)")
            return nil
        }
        
    }
    
    func testStorageSettings() {
        self.logger?.log(tag: RSFileStorage.TAG, level: .info, message: "Testing storage settings")
        //test that directory holding realm file does not back stuff up
        do {
            let resourceValues = try self.storageDirectory.resourceValues(forKeys: [.isExcludedFromBackupKey])
            assert(resourceValues.isExcludedFromBackup == true)
        }
        catch _ {
            self.logger?.log(tag: RSFileStorage.TAG, level: .error, message: "The storage directory is NOT excluded fromn backup")
            assertionFailure()
        }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: self.storageDirectory.path)
            if let protectionKey = attributes[.protectionKey] as? FileProtectionType {
                let expectedFileProtection = self.expectedFileProtection()
                if protectionKey != expectedFileProtection {
                    self.logger?.log(tag: RSFileStorage.TAG, level: .error, message: "The protection key \(protectionKey.rawValue) is not the configured key \(expectedFileProtection.rawValue)")
                }
                
                assert(protectionKey == expectedFileProtection)
            }
            else {
                #if targetEnvironment(simulator)
                #else
                self.logger?.log(tag: RSFileStorage.TAG, level: .error, message: "Unable to query the file protection key")
                assertionFailure()
                #endif
                
            }
        }
        catch let error {
            self.logger?.log(tag: RSFileStorage.TAG, level: .error, message: "An error occurred when testing the file protection \(error)")
            assertionFailure()
        }
        
        self.logger?.log(tag: RSFileStorage.TAG, level: .info, message: "Storage is configured properly")
    }
    
    func expectedFileProtection() -> FileProtectionType {
        #if targetEnvironment(simulator)
        return .completeUntilFirstUserAuthentication
        #else
        return self.storageDirectoryFileProtection
        #endif
    }
    
    
}
