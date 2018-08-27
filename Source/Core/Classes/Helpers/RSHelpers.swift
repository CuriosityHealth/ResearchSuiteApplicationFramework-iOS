//
//  RSHelpers.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/23/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import Gloss

public class RSHelpers {
    
    open static func getJSON(fileName: String, inDirectory: String? = nil, configJSONBaseURL: String? = nil) -> JSON? {
        
        let urlPath: String = inDirectory != nil ? inDirectory! + "/" + fileName : fileName
        guard let urlBase = configJSONBaseURL,
            let url = URL(string: urlBase + urlPath) else {
                return nil
        }
        
        return RSHelpers.getJSON(forURL: url)
    }
    
    open static func getJSON(forURL url: URL) -> JSON? {
        
//        print(url)
        guard let fileContent = try? Data(contentsOf: url)
            else {
                assertionFailure("Unable to create NSData with content of file \(url)")
                return nil
        }
        
        guard let json = (try? JSONSerialization.jsonObject(with: fileContent, options: JSONSerialization.ReadingOptions.mutableContainers)) as? JSON else {
            return nil
        }
        
        return json
    }
    
    open static func writeJSON(json: JSON, toURL url: URL) -> Bool {
        
        if JSONSerialization.isValidJSONObject(json) {
            
            guard let data = try? JSONSerialization.data(withJSONObject: json, options: .init(rawValue: 0)) else {
                return false
            }
            
            do {
                try data.write(to: url, options: .atomicWrite)
                return true
            }
            catch {
                return false
            }
        }
        else {
            return false
        }
        
    }
    
    public static func getJson(forFilename filename: String, inBundle bundle: Bundle = Bundle.main, inDirectory: String? = nil) -> JsonElement? {
        
        assertionFailure("This method is deprecated. Use getJSON(forURL)")
        
        guard let filePath = bundle.path(forResource: filename, ofType: "json", inDirectory: inDirectory) else {
                assertionFailure("unable to locate file \(filename)")
                return nil
        }
        
        guard let fileContent = try? Data(contentsOf: URL(fileURLWithPath: filePath))
            else {
                assertionFailure("Unable to create NSData with content of file \(filePath)")
                return nil
        }
        
        let json = try! JSONSerialization.jsonObject(with: fileContent, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        return json as JsonElement?
    }
    
    public static func delay(_ delay:TimeInterval, dispatchQueue: DispatchQueue = DispatchQueue.main,  closure:@escaping ()->()) {
        dispatchQueue.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

}
