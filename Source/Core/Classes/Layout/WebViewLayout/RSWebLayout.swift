//
//  RSWebLayout.swift
//  Pods
//
//  Created by James Kizer on 5/24/18.
//

import UIKit
import Gloss

open class RSWebLayout: RSBaseLayout, RSLayoutGenerator  {
    
    public static func supportsType(type: String) -> Bool {
        return type == "webView"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager, state: RSState) -> RSLayout? {
        return RSWebLayout(json: jsonObject)
    }
    
    public let urlBase: JSON
    public let urlPath: JSON
    
    required public init?(json: JSON) {
        
        guard let urlBase: JSON = "urlBase" <~~ json,
            let urlPath: JSON = "urlPath" <~~ json else {
                return nil
        }

        self.urlBase = urlBase
        self.urlPath = urlPath
        
        super.init(json: json)
    }
    
    open override func isEqualTo(_ object: Any) -> Bool {
        
        assertionFailure()
        return false
        
    }
    
    open override func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController {
        
//        let bundle = Bundle(for: RSCalendarLayout.self)
//        let storyboard: UIStoryboard = UIStoryboard(name: "RSViewControllers", bundle: bundle)
//
//        guard let layoutVC = storyboard.instantiateViewController(withIdentifier: "calendarLayoutViewController") as? RSCalendarLayoutViewController else {
//            throw RSLayoutError.cannotInstantiateLayout(layoutIdentifier: self.identifier)
//        }
        
        let layoutVC = RSWebLayoutViewController()
        
        layoutVC.matchedRoute = matchedRoute
        layoutVC.parentLayoutViewController = parent
        
        return layoutVC
    }
        
}
