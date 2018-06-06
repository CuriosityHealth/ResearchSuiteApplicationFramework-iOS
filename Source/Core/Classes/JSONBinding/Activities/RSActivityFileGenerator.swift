//
//  RSActivityFileGenerator.swift
//  Pods
//
//  Created by James Kizer on 6/4/18.
//

import UIKit
import Gloss

open class RSActivityFileDescriptor {
    
    public let filename: String?
    public let URLPath: String?
    public let URLBaseKey: String
    
    required public init?(json: JSON) {
        
        self.filename = "filename" <~~ json
        self.URLBaseKey = "URLBaseKey" <~~ json ?? "configJSONBaseURL"
        self.URLPath = "URLPath" <~~ json
        
    }
    
}

open class RSActivityFileGenerator: RSActivityGenerator {
    
    public static func supportsType(type: String?) -> Bool {
        guard let type = type else {
            return false
        }
        
        return type == "activityFile"
    }
    
    private static func loadJSON(descriptor: RSActivityFileDescriptor) -> JSON? {
        if let urlBase = RSApplicationDelegate.appDelegate.taskBuilderStateHelper.valueInState(forKey: descriptor.URLBaseKey) as? String,
            let urlPath = descriptor.URLPath,
            let url = URL(string: urlBase + urlPath) {
            
            return RSHelpers.getJSON(forURL: url)
            
        }
        else if let filename = descriptor.filename {
            return RSHelpers.getJson(forFilename: filename) as? JSON
        }
        else {
            return nil
        }
    }
    
    public static func generate(jsonObject: JSON, activityManager: RSActivityManager) -> RSActivity? {
        guard let descriptor: RSActivityFileDescriptor = RSActivityFileDescriptor(json: jsonObject),
            let json = RSActivityFileGenerator.loadJSON(descriptor: descriptor) else {
                return nil
        }
        
        return activityManager.generate(jsonObject: json)
    }
    
}
