//
//  RSLicenseLayout.swift
//  Pods
//
//  Created by James Kizer on 1/24/19.
//

import UIKit
import Gloss

open class RSLicenseLayout: RSBaseLayout, RSLayoutGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "license"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager, state: RSState) -> RSLayout? {
        return RSLicenseLayout(jsonObject: jsonObject, state: state)
    }
    
    public let acknowledgementsFilePath: String
    
    public init?(jsonObject: JSON, state: RSState) {
        
        guard let urlBaseJSON: JSON = "urlBase" <~~ jsonObject,
            let urlBase = RSValueManager.processValue(jsonObject: urlBaseJSON, state: state, context: [:])?.evaluate() as? String,
            let urlPathJSON: JSON = "urlPath" <~~ jsonObject,
            let urlPath = RSValueManager.processValue(jsonObject: urlPathJSON, state: state, context: [:])?.evaluate() as? String else {
                return nil
        }
        
        self.acknowledgementsFilePath = urlBase + urlPath
        
        super.init(json: jsonObject)
    }
    
    required public init?(json: JSON) {
        return nil
    }
    
    
    open override func isEqualTo(_ object: Any) -> Bool {
        
        assertionFailure()
        return false
        
    }
    
    open override func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController {
        
        
        let licenseVC = RSLicenseViewController()
        licenseVC.acknowledgementsFilePath = self.acknowledgementsFilePath
        
        let containerVC = RSContainerLayoutViewController()
        containerVC.childViewController = licenseVC
        
        containerVC.matchedRoute = matchedRoute
        containerVC.parentLayoutViewController = parent
        
        return containerVC
        
    }
    
}
