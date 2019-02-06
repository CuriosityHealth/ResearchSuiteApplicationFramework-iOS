//
//  RSMeasureFileGenerator.swift
//  Pods
//
//  Created by James Kizer on 2/1/19.
//

import UIKit
import Gloss

open class RSMeasureFileDescriptor {
    
    public let filename: String?
    public let URLPath: String?
    public let URLBaseKey: String
    
    required public init?(json: JSON) {
        
        self.filename = "filename" <~~ json
        self.URLBaseKey = "URLBaseKey" <~~ json ?? "configJSONBaseURL"
        self.URLPath = "URLPath" <~~ json
        
    }
    
}

open class RSMeasureFileGenerator: RSMeasureGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "measureFile"
    }
    
    private static func loadJSON(descriptor: RSMeasureFileDescriptor, state: RSState) -> JSON? {
        
        guard let urlBase = RSStateSelectors.getValueInCombinedState(state, for: descriptor.URLBaseKey) as? String else {
            return nil
        }
        
        if let urlPath = descriptor.URLPath,
            let url = URL(string: urlBase + urlPath) {
            return RSHelpers.getJSON(forURL: url)
        }
        else if let filename = descriptor.filename {
            return RSHelpers.getJSON(fileName: filename, configJSONBaseURL: urlBase)
        }
        else {
            return nil
        }
    }
    
    public static func generate(jsonObject: JSON, measureManager: RSMeasureManager, state: RSState) -> RSMeasure? {
        guard let descriptor: RSMeasureFileDescriptor = RSMeasureFileDescriptor(json: jsonObject),
            let json = RSMeasureFileGenerator.loadJSON(descriptor: descriptor, state: state) else {
                return nil
        }
        
        return measureManager.generate(jsonObject: json, state: state)
    }
    
}
