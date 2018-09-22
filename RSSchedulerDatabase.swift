//
//  RSSchedulerDatabase.swift
//  Pods
//
//  Created by James Kizer on 9/19/18.
//

import UIKit
import RealmSwift
import Realm
import ResearchSuiteExtensions

open class RSSchedulerDatabase: NSObject {
    
    
    static let kDatabaseKey = "rs_scheduler_database_key"
    static let kFileUUID = "rs_scheduler_database_file_uuid"
    
    static var TAG = "RSSchedulerDatabase"
    public var logger: RSLogger?
    
    
    var credentialStore: RSCredentialsStore!
    open let realmFile: URL
    let encryptionEnabled: Bool
    let fileProtection: FileProtectionType
    let schemaVersion: UInt64 = 0
    
    //realm config
    var _realmConfig: Realm.Configuration?
    var realmConfig: Realm.Configuration {
        if let config = self._realmConfig {
            return config
        }
        else {
            let config = Realm.Configuration(
                fileURL: self.realmFile,
                inMemoryIdentifier: nil,
                syncConfiguration: nil,
                encryptionKey: self.encryptionEnabled ? (self.credentialStore.get(key: RSSchedulerDatabase.kDatabaseKey) as? NSData)! as Data: nil,
                readOnly: false,
                schemaVersion: self.schemaVersion,
                migrationBlock: nil,
                deleteRealmIfMigrationNeeded: false,
                shouldCompactOnLaunch: nil,
                objectTypes: nil)
            
            self._realmConfig = config
            return config
        }
    }
    
    //Also, specify data protection setting
    public init?(
        databaseStorageDirectory: String,
        databaseFileName: String,
        encrypted: Bool,
        credentialStore: RSCredentialsStore,
        fileProtection: FileProtectionType,
        logger: RSLogger? = nil
        ) {
        
        self.credentialStore = credentialStore
        
        let fileUUID: UUID = {
            if let uuid = credentialStore.get(key: RSSchedulerDatabase.kFileUUID) as? NSUUID {
                return uuid as UUID
            }
            else {
                let uuid = UUID()
                credentialStore.set(value: uuid as NSUUID, key: RSSchedulerDatabase.kFileUUID)
                return uuid
            }
        }()
        
        self.encryptionEnabled = encrypted
        if encrypted {
            //check to see if a db key has been set
            if let _ = self.credentialStore.get(key: RSSchedulerDatabase.kDatabaseKey) {
                
            }
            else {
                var key = Data(count: 64)
                _ = key.withUnsafeMutableBytes { bytes in
                    SecRandomCopyBytes(kSecRandomDefault, 64, bytes)
                }
                
                self.credentialStore.set(value: key as NSData, key: RSSchedulerDatabase.kDatabaseKey)
            }
            
            
        }
        
        
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .warn, message: "Database failed initialization")
            return nil
        }
        
        let finalDatabaseDirectory = documentsPath.appending("/\(databaseStorageDirectory)/\(fileUUID.uuidString)")
        var isDirectory : ObjCBool = false
        if FileManager.default.fileExists(atPath: finalDatabaseDirectory, isDirectory: &isDirectory) {
            
            //if a file, remove file and add directory
            if isDirectory.boolValue {
                
            }
            else {
                self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .warn, message: "File found at database directory. Removing...")
                do {
                    try FileManager.default.removeItem(atPath: finalDatabaseDirectory)
                } catch let error as NSError {
                    //TODO: handle this
                    self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .error, message: "An error occurred removing the file: \(error)")
                    //                    print(error.localizedDescription);
                }
            }
            
        }
        
        do {
            self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .info, message: "Configuring database directory: \(finalDatabaseDirectory)")
            self.fileProtection = fileProtection
            try FileManager.default.createDirectory(atPath: finalDatabaseDirectory, withIntermediateDirectories: true, attributes: [.protectionKey: fileProtection])
            var url: URL = URL(fileURLWithPath: finalDatabaseDirectory)
            var resourceValues: URLResourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try url.setResourceValues(resourceValues)
            
        } catch let error as NSError {
            //TODO: Handle this
            self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .error, message: "An error occurred configuring the database directory: \(error)")
            //            print(error.localizedDescription);
        }
        //
        let finalDatabaseFilePath = finalDatabaseDirectory.appending("/\(databaseFileName)")
        self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .info, message: "The final database file is: \(finalDatabaseFilePath)")
        self.realmFile = URL(fileURLWithPath: finalDatabaseFilePath)
        
        super.init()
        
        self.testRealmFileSettings()

    }
    
    func testRealmFileSettings() {
        self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .info, message: "Testing realm settings")
        //test that directory holding realm file does not back stuff up
        let realmDirectory = self.realmFile.deletingLastPathComponent()
        do {
            let resourceValues = try realmDirectory.resourceValues(forKeys: [.isExcludedFromBackupKey])
            assert(resourceValues.isExcludedFromBackup == true)
        }
        catch _ {
            self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .error, message: "The realm directory is NOT excluded fromn backup")
            assertionFailure()
        }
        
        
        //only do it if the realm file exists
        if FileManager.default.fileExists(atPath: self.realmFile.path) {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: self.realmFile.path)
                if let protectionKey = attributes[.protectionKey] as? FileProtectionType {
                    let expectedFileProtection = self.expectedFileProtection()
                    if protectionKey != expectedFileProtection {
                        self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .error, message: "The protection key \(protectionKey.rawValue) is not the configured key \(expectedFileProtection.rawValue)")
                    }
                    
                    assert(protectionKey == expectedFileProtection)
                }
                else {
                    #if targetEnvironment(simulator)
                    #else
                    self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .error, message: "Unable to query the file protection key")
                    assertionFailure()
                    #endif
                    
                }
            }
            catch let error {
                self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .error, message: "An error occurred when testing the file protection \(error)")
                assertionFailure()
            }
        }
        
        if self.encryptionEnabled && self.credentialStore.get(key: RSSchedulerDatabase.kDatabaseKey) == nil {
            self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .error, message: "Encryption is misconfigured")
            assertionFailure()
        }
        
        self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .info, message: "Realm is configured properly")
    }
    
    func expectedFileProtection() -> FileProtectionType {
        #if targetEnvironment(simulator)
        return .completeUntilFirstUserAuthentication
        #else
        return self.fileProtection
        #endif
    }
    
    public func deleteRealm(completion: @escaping ((Error?) -> ())) {
        
        do {
            
            self.logger?.log(tag: RSSchedulerDatabase.TAG, level: .info, message: "Deleting realm")
            
            //clear file key first so that even if an error occurs, the encryption key is no longer available
            self.credentialStore.set(value: nil, key: RSSchedulerDatabase.kDatabaseKey)
            self.credentialStore.set(value: nil, key: RSSchedulerDatabase.kFileUUID)
            
            try autoreleasepool {
                let configuration = self.realmConfig
                let realm = try Realm(configuration: configuration)
                
                try realm.write {
                    realm.deleteAll()
                }
                
            }
            
            
            self._realmConfig = nil
            try FileManager.default.removeItem(at: self.realmFile)
            try FileManager.default.removeItem(at: self.realmFile.deletingLastPathComponent())
            
            completion(nil)
            
        } catch let error {
            
            self._realmConfig = nil
            try? FileManager.default.removeItem(at: self.realmFile)
            try? FileManager.default.removeItem(at: self.realmFile.deletingLastPathComponent())
            
            completion(error)
        }
        
    }
    
    //add scheduler events
    public func addSchedulerEvents(scheduleEvents: [RSRealmScheduleEvent]) throws {
        
        let error: Error? = autoreleasepool {
            do {
                let realm = try Realm(configuration: self.realmConfig)
                try realm.write {
                    realm.add(scheduleEvents)
                }
                
              return nil
                
            } catch let error as NSError {
                // handle error
                return error
            }
        }
        
        if let err = error {
            throw err
        }

    }
    
    //remove scheduler events
    public func removeSchedulerEvents(scheduleEvents: [RSRealmScheduleEvent]) throws {
        
        let error: Error? = autoreleasepool {
            do {
                let realm = try Realm(configuration: self.realmConfig)
                try realm.write {
                    realm.delete(scheduleEvents)
                }
                
                return nil
                
            } catch let error as NSError {
                // handle error
                return error
            }
        }
        
        if let err = error {
            throw err
        }
        
    }
    
    public func getSchedulerEvents(eventType: String? = nil, completed: Bool? = nil) throws -> [RSRealmScheduleEvent] {
        let realm = try Realm(configuration: self.realmConfig)
        
        var results = realm.objects(RSRealmScheduleEvent.self)
        if let et = eventType {
            let filterString = "eventType == '\(et)'"
            results = results.filter(filterString)
        }
        
        if let completed = completed {
            let filterString = completed ? "completed == true" : "completed == false"
            results = results.filter(filterString)
        }

        return Array(results)
    }
    
    //mark event as completed
    public func markEventCompleted(eventIdentifier: String, completed: Bool) throws {
        
        let error: Error? = autoreleasepool {
            do {
                let realm = try Realm(configuration: self.realmConfig)
                guard let event = realm.objects(RSRealmScheduleEvent.self).filter("identifier == '\(eventIdentifier)'").first else {
                    return nil
                }
                
                try realm.write {
                    event.completed = completed
                    event.completionTime = Date()
                }
                
                return nil
                
            } catch let error as NSError {
                // handle error
                return error
            }
        }
        
        if let err = error {
            throw err
        }
        
    }

}
