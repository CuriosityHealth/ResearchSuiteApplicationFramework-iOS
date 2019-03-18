//
//  RSPDFViewerLayout.swift
//  Pods
//
//  Created by James Kizer on 2/28/19.
//

import UIKit
import Gloss

open class RSPDFViewerLayout: RSBaseLayout, RSLayoutGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "pdf"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager, state: RSState) -> RSLayout? {
        return RSPDFViewerLayout(jsonObject: jsonObject, state: state)
    }
    
    public let pdfFilePath: String
    
    public init?(jsonObject: JSON, state: RSState) {
        
        guard let urlBaseJSON: JSON = "urlBase" <~~ jsonObject,
            let urlBase = RSValueManager.processValue(jsonObject: urlBaseJSON, state: state, context: [:])?.evaluate() as? String,
            let urlPathJSON: JSON = "urlPath" <~~ jsonObject,
            let urlPath = RSValueManager.processValue(jsonObject: urlPathJSON, state: state, context: [:])?.evaluate() as? String else {
                return nil
        }
        
        self.pdfFilePath = urlBase + urlPath
        
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
        
        
        let pdfVC = RSPDFViewerViewController()
        pdfVC.pdfFilePath = self.pdfFilePath
        
        let containerVC = RSContainerLayoutViewController()
        containerVC.childViewController = pdfVC
        
        containerVC.matchedRoute = matchedRoute
        containerVC.parentLayoutViewController = parent
        
        return containerVC
        
    }
    
}
