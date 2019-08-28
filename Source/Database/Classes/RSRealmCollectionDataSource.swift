//
//  RSRealmCollectionDataSource.swift
//  Pods
//
//  Created by James Kizer on 5/17/18.
//

import UIKit
import LS2SDK
import RealmSwift

public protocol RSRealmDataSource: RSDataSource {
    func getRealm() -> Realm
}

extension LS2RealmDatapoint: RSCollectionDataSourceElement {
    
    public var primaryDate: Date? {
        return self.header?.acquisitionProvenance.sourceCreationDateTime
    }
    
}

open class RSRealmCollectionDataSource: RSCollectionDataSource {
    
    public let identifier: String
    var results: Results<LS2RealmDatapoint>? = nil
    var notificationToken: NotificationToken? = nil
    
    public init?(identifier: String, databaseManager: LS2DatabaseManager, predicates: [NSPredicate], sortSettings: RSSortSettings?) {
        
        guard let realm = databaseManager.getRealm(),
            let objects = realm.objects(LS2RealmDatapoint.self) else {
                return nil
        }
        
        self.identifier = identifier
        
        let filteredObjects = predicates.reduce(objects, { (accObjects, predicate) -> Results<LS2RealmDatapoint> in
            return accObjects.filter(predicate)
        })
        
        let sortedObjects: Results<LS2RealmDatapoint> = {
            if let settings = sortSettings {
                return filteredObjects.sorted(byKeyPath: settings.keyPath, ascending: settings.ascending)
            }
            else {
                return filteredObjects
            }
        }()
        
        self.results = sortedObjects
        
    }
    
    public init?(identifier: String, databaseManager: LS2DatabaseManager, predicates: [NSPredicate], sortSettings: RSSortSettings?, readyCallback: @escaping (RSCollectionDataSource)->(), updateCallback: @escaping ((RSCollectionDataSource, [Int], [Int], [Int]) -> ())) {
        
        guard let realm = databaseManager.getRealm(),
            let objects = realm.objects(LS2RealmDatapoint.self) else {
                return nil
        }

        self.identifier = identifier
        
        let filteredObjects = predicates.reduce(objects, { (accObjects, predicate) -> Results<LS2RealmDatapoint> in
            return accObjects.filter(predicate)
        })
        
        let sortedObjects: Results<LS2RealmDatapoint> = {
            if let settings = sortSettings {
                return filteredObjects.sorted(byKeyPath: settings.keyPath, ascending: settings.ascending)
            }
            else {
                return filteredObjects
            }
        }()
        
        
        self.notificationToken = sortedObjects.observe { [unowned self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                readyCallback(self)
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                updateCallback(self, deletions, insertions, modifications)
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
        
        self.results = sortedObjects
        
    }
    
    deinit {
        self.notificationToken?.invalidate()
    }
    
    open func invalidate() {
        self.notificationToken?.invalidate()
    }
    
    open var count: Int? {
        
        guard let results = self.results,
            !results.isInvalidated else {
                return nil
        }
        
        return results.count
    }
    
    open var updateCallback: ((Int, Int, Int) -> ())?
    
    open func get(for index: Int) -> RSCollectionDataSourceElement? {
        guard let results = self.results,
            !results.isInvalidated else {
                return nil
        }
        
        return results[index]
    }
    
    open func toArray() -> [RSCollectionDataSourceElement]? {
        guard let results = self.results,
            !results.isInvalidated else {
                return nil
        }
        
        return Array(results)
    }
    
    open func generateDictionary() -> [Int : RSCollectionDataSourceElement]? {
        
        guard let results = self.results,
            !results.isInvalidated else {
                return nil
        }
        
        var returnDict: [Int : RSCollectionDataSourceElement] = [:]
        (0..<results.count).forEach { (index) in
            returnDict[index] = results[index]
        }
        
        return returnDict
        
    }
    
}
