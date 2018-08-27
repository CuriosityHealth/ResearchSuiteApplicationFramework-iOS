//
//  RSConfigBundleCache.swift
//  Pods
//
//  Created by James Kizer on 6/28/18.
//

import UIKit
import Alamofire
import Gloss
import ResearchSuiteApplicationFramework
import ResearchSuiteExtensions
import Zip

public protocol RSConfigBundleCacheDelegate: class {
    func onNewBundle(localURL: URL?, bundleInfo: RSConfigBundleInfo?)
}

public struct RSConfigBundleInfo: Glossy {
    
    let id: UUID
    let url: URL
    let date: Date
    let appBundleVersion: String
    let appVersion: String
    var valid: Bool
    var successfullyLoaded: Bool
    
    public init?(json: JSON) {
        guard let id: UUID = "id" <~~ json,
            let url: URL = "url" <~~ json,
            let dateString: String = "date" <~~ json,
            let date = ISO8601DateFormatter().date(from: dateString),
            let appBundleVersion: String = "app_bundle_version" <~~ json,
            let appVersion: String = "app_version" <~~ json else {
                return nil
        }
        
        self.id = id
        self.url = url
        self.date = date
        self.appBundleVersion = appBundleVersion
        self.appVersion = appVersion
        self.valid = "valid" <~~ json ?? true
        self.successfullyLoaded = "successfully_loaded" <~~ json ?? false
        
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "url" ~~> self.url,
            Gloss.Encoder.encode(dateISO8601ForKey: "date")(self.date),
            "app_bundle_version" ~~> self.appBundleVersion,
            "app_version" ~~> self.appVersion,
            "valid" ~~> self.valid,
            "successfully_loaded" ~~> self.successfullyLoaded
            ])
    }
}

//TODO: if we crash before we load due to bad config files, we may end up in a loop where we continue to crash and we can never
//download new files. This is bad. We could have a flag that would still let the cache download new configs, but it would use the
//built in files instead of the cached files
open class RSConfigBundleCache: NSObject  {
    
    open weak var delegate: RSConfigBundleCacheDelegate?
    
    let baseURL: String
    let bundleStorageDirectory: String
    let appBundleVersion: String
    let appVersion: String
    
    let cachedBundlesInfoFile: URL
    var currentBundle: RSConfigBundleInfo?
    var bundles: [UUID: RSConfigBundleInfo]!
    
    let dispatchQueue: DispatchQueue
    
    public init(baseURL: String, bundleStorageDirectory: String, appBundleVersion: String, appVersion: String) {
        
        self.baseURL = baseURL
        self.bundleStorageDirectory = bundleStorageDirectory
        self.cachedBundlesInfoFile = URL(fileURLWithPath: bundleStorageDirectory).appendingPathComponent("bundles.json")
        self.appBundleVersion = appBundleVersion
        self.appVersion = appVersion
        
        self.dispatchQueue = DispatchQueue.main
        
        super.init()
        //load current bundles that are on disk
        //bundles and current bundle are by default empty
        self.bundles = [:]
        self.currentBundle = nil
        
        var isDirectory : ObjCBool = false
        if FileManager.default.fileExists(atPath: self.bundleStorageDirectory, isDirectory: &isDirectory) {
            
            //if a file, remove file and add directory
            if isDirectory.boolValue {
                
                if FileManager.default.fileExists(atPath: self.cachedBundlesInfoFile.path),
                    let bundlesJSON: JSON = RSHelpers.getJSON(forURL: self.cachedBundlesInfoFile),
                    let bundlesArrayJSON: [JSON] = "bundles" <~~ bundlesJSON {
                    
                    let cachedBundles: [RSConfigBundleInfo] = bundlesArrayJSON.compactMap({ RSConfigBundleInfo(json: $0) })
                    
                    //do some validation to make sure the bundles are ok
                    
                    let pairs: [(UUID, RSConfigBundleInfo)] = cachedBundles.map { ($0.id, $0) }
                    self.bundles = Dictionary.init(uniqueKeysWithValues: pairs)
                    
                    self.currentBundle = self.computeCurrentBundle(bundles: self.bundles, skipSuccessfullyLoadedCheck: false)
                    
                }
                
            }
            else {
                assertionFailure()
            }
            
        }
        else {
            
            do {
                //make directory
                try FileManager.default.createDirectory(atPath: self.bundleStorageDirectory, withIntermediateDirectories: true, attributes: nil)
                var url: URL = URL(fileURLWithPath: self.bundleStorageDirectory)
                var resourceValues: URLResourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try url.setResourceValues(resourceValues)
            }
            catch {
                assertionFailure()
            }
            
            
        }
        
        self.checkBundles()
        
    }
    
    open func computeCurrentBundle(bundles: [UUID: RSConfigBundleInfo], skipSuccessfullyLoadedCheck: Bool) -> RSConfigBundleInfo? {
        let currentBundle = bundles.values.filter({ self.isCompatible(bundleInfo: $0) && $0.valid && (skipSuccessfullyLoadedCheck || $0.successfullyLoaded) }).sorted(by: { $0.date > $1.date }).first
        return currentBundle
    }
    
    open func configurationCompleted(success: Bool) {
        if var bundle = self.currentBundle,
            bundle.successfullyLoaded != success {
            
            bundle.successfullyLoaded = success
            self.currentBundle = bundle
            self.bundles[bundle.id] = bundle
            self.writeBundles(bundles: self.bundles)
            
        }
    }
    
    open func isCompatible(bundleInfo: RSConfigBundleInfo) -> Bool {
        return bundleInfo.appVersion == self.appVersion && bundleInfo.appBundleVersion == self.appBundleVersion
    }
    
    //this looks for new bundles and potentially invalidates old ones
    //need to test
    // normal case: no updates
    // new bundle case
    // invalidated bundle case
    // invalidated current bundle case
    open func checkBundles() {
        
        self.fetchBundlesJSON { (bundles, error) in
            
            if let bundles = bundles {
                
                let completionClosure: (Bool, [UUID: RSConfigBundleInfo]) -> () = { bundlesUpdated, bundles in
                    if bundlesUpdated {
                        self.writeBundles(bundles: bundles)
                        self.bundles = bundles
                        self.currentBundle = self.computeCurrentBundle(bundles: bundles, skipSuccessfullyLoadedCheck: true)
                        let localURL: URL? = self.currentBundle != nil ? URL(fileURLWithPath: self.bundleStorageDirectory).appendingPathComponent(self.currentBundle!.id.uuidString) : nil
                        DispatchQueue.main.async {
                            self.delegate?.onNewBundle(localURL: localURL, bundleInfo: self.currentBundle)
                        }
                    }
                }
                
                var localBundles: [UUID: RSConfigBundleInfo] = self.bundles
                var localBundlesUpdated = false
                
                
                //we've successfuly fetched the bundles config file
                //first, check for invalidated bundles
                bundles.forEach({ (bundleInfo) in
                    
                    if var cachedBundle = localBundles[bundleInfo.id],
                        bundleInfo.valid != cachedBundle.valid {
                        
                        cachedBundle.valid = bundleInfo.valid
                        localBundles[cachedBundle.id] = cachedBundle
                        localBundlesUpdated = true
                    }
                    
                })
                
                
                let compatibleAndValidBundles: [RSConfigBundleInfo] = bundles.filter({ self.isCompatible(bundleInfo: $0) }).filter { $0.valid }
                if let latestBundle = compatibleAndValidBundles.sorted(by: {$0.date > $1.date}).first {
                    
                    //check to see if we have the bundle
                    if !localBundles.keys.contains(latestBundle.id) {
                        self.fetchBundle(bundleInfo: latestBundle) { successful in
                            
                            if successful {
                                localBundles[latestBundle.id] = latestBundle
                                localBundlesUpdated = true
                            }
                            
                            completionClosure(localBundlesUpdated, localBundles)
                            return
                            
                        }
                        
                    }
                    else {
                        completionClosure(localBundlesUpdated, localBundles)
                        return
                    }
                    
                }
                else {
                    completionClosure(localBundlesUpdated, localBundles)
                    return
                }
                
                
            }
            
        }
        
        
    }
    
    //    open func checkForInvalidatedBundles(completion: @escaping (Bool) -> ()) {
    //        self.fetchBundlesJSON { (bundles, error) in
    //            //            print(bundles)
    //
    //            var updateBundlesOnDisk = false
    //            var currentBundleInvalidated = false
    //
    //            if let bundles = bundles {
    //
    //                bundles.forEach({ (bundleInfo) in
    //
    //                    if var cachedBundle = self.bundles[bundleInfo.id],
    //                        !bundleInfo.valid,
    //                        cachedBundle.valid {
    //
    //                        cachedBundle.valid = false
    //                        self.bundles[cachedBundle.id] = cachedBundle
    //                        updateBundlesOnDisk = true
    //
    //                        if let currentBundle = self.currentBundle,
    //                            currentBundle.id == cachedBundle.id {
    //                            self.currentBundle = cachedBundle
    //                            currentBundleInvalidated = true
    //                        }
    //                    }
    //
    //                })
    //
    //                if updateBundlesOnDisk {
    //                    self.writeBundles(bundles: self.bundles)
    //                }
    //
    //            }
    //
    //            completion(currentBundleInvalidated)
    //        }
    //
    //    }
    //
    //    //
    //    open func fetchLatestBundle() {
    //
    //        //first, fetch bundles file
    //        self.fetchBundlesJSON { (bundles, error) in
    ////            print(bundles)
    //
    //            if let bundles = bundles {
    //                //filter bundles by configured app bundle version
    //                //sort them to get the latest
    //                let compatibleAndValidBundles: [RSConfigBundleInfo] = bundles.filter({ self.isCompatible(bundleInfo: $0) }).filter { $0.valid }
    //                if let latestBundle = compatibleAndValidBundles.sorted(by: {$0.date > $1.date}).first {
    //
    //                    //check to see if we have the bundle
    //                    if !self.bundles.keys.contains(latestBundle.id) {
    //                        self.fetchBundle(bundleInfo: latestBundle)
    //
    //                    }
    //
    //                }
    //            }
    //
    //
    ////            print(error)
    //        }
    //
    //        //
    //
    //    }
    //
    open func writeBundles(bundles: [UUID: RSConfigBundleInfo]) {
        let bundles: [RSConfigBundleInfo] = Array(bundles.values)
        if let json: JSON = "bundles" ~~> bundles {
            let _ = RSHelpers.writeJSON(json: json, toURL: self.cachedBundlesInfoFile)
        }
    }
    
    open func fetchBundle(bundleInfo: RSConfigBundleInfo, completion: @escaping (Bool)->() ) {
        
        let archiveFileURL = URL(fileURLWithPath: self.bundleStorageDirectory).appendingPathComponent("archives/\(bundleInfo.id).zip")
        
        //download file
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (archiveFileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(bundleInfo.url, to: destination).response { response in
            print(response)
            
//            debugPrint(response.error)
            if response.error == nil, let archiveURL = response.destinationURL {
                
                print("Archive has been downloaded to \(archiveURL)")
                let destinationURL = URL(fileURLWithPath: self.bundleStorageDirectory).appendingPathComponent(bundleInfo.id.uuidString)
                do {
                    try Zip.unzipFile(archiveURL, destination: destinationURL, overwrite: true, password: nil)
                    
                    print("Archive has been unzipped to \(destinationURL)")
                    //assume this was successful, update bundles
                    
                    completion(true)
                    return
                    
                }
                catch {
                    completion(false)
                    return
                }
            }
            else {
                completion(false)
                return
            }
        }
        //extract file to directory
        
    }
    
    open func localURLForBundleInfo(bundleInfo: RSConfigBundleInfo) -> URL {
        return URL(fileURLWithPath: self.bundleStorageDirectory).appendingPathComponent(bundleInfo.id.uuidString)
    }
    
    //gets the latest bundle in the
    open func latestBundle(defaultBundle: URL) -> URL {
        
        guard let currentBundle = self.currentBundle else {
            return defaultBundle
        }
        
        return self.localURLForBundleInfo(bundleInfo: currentBundle)
    }
    
    open func fetchBundlesJSON(completion: @escaping (([RSConfigBundleInfo]?, Error?) -> ())) {
        let urlString = "\(self.baseURL)/bundles.json"
        
        let request = Alamofire.request(
            urlString,
            method: .get,
            encoding: JSONEncoding.default
        )
        
        request.responseJSON(queue: self.dispatchQueue, completionHandler: self.processBundlesJSONResponse(completion: completion))
    }
    
    private func processBundlesJSONResponse(completion: @escaping (([RSConfigBundleInfo]?, Error?) -> ())) -> (DataResponse<Any>) -> () {
        
        return { jsonResponse in
            //check for actually success
            
            switch jsonResponse.result {
            case .success:
                guard let response = jsonResponse.response else {
                    completion(nil, nil)
                    return
                }
                
                switch (response.statusCode) {
                case 200:
                    
                    guard let json = jsonResponse.result.value as? JSON,
                        let bundlesJSON: [JSON] = "bundles" <~~ json else {
                            completion(nil, nil)
                            return
                    }
                    
                    let bundleInfos: [RSConfigBundleInfo] = bundlesJSON.compactMap({ RSConfigBundleInfo(json: $0) })
                    completion(bundleInfos, nil)
                    
                    return
                    
                case 401:
                    completion(nil, nil)
                    return
                    
                case 403:
                    completion(nil, nil)
                    return
                    
                case 404:
                    completion(nil, nil)
                    return
                    
                case 500:
                    completion(nil, nil)
                    return
                    
                case 502:
                    completion(nil, nil)
                    return
                    
                default:
                    
                    completion(nil, nil)
                    return
                    
                }
                
                
            case .failure(let error):
                let nsError = error as NSError
                completion(nil, nsError)
            }
        }
        
        
    }
    
}
