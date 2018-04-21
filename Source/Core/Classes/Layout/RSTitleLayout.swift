//
//  RSTitleLayout.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/12/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSTitleLayout: RSBaseLayout, RSLayoutGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "title"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager) -> RSLayout? {
        return RSTitleLayout(json: jsonObject)
    }
    
    
    open let title: String
    open let image: UIImage?
    open let button: RSLayoutButton?
    
    required public init?(json: JSON) {
        
        guard let title: String = "title" <~~ json else {
            return nil
        }
        
        self.title = title
        
        self.image = {
            if let imageTitle: String = "image" <~~ json {
                return UIImage(named: imageTitle)
            }
            else {
                return nil
            }
        }()
        
        self.button = "button" <~~ json
        
        super.init(json: json)
        
    }

    
    open override func isEqualTo(_ object: Any) -> Bool {
        
        assertionFailure()
        return false
        
    }
    
    open override func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController {
        
        let bundle = Bundle(for: RSTitleLayout.self)
        let storyboard: UIStoryboard = UIStoryboard(name: "RSViewControllers", bundle: bundle)
        
        guard let titleLayoutVC = storyboard.instantiateViewController(withIdentifier: "titleLayoutViewController") as? RSLayoutTitleViewController else {
            throw RSLayoutError.cannotInstantiateLayout(layoutIdentifier: self.identifier)
        }
        
        titleLayoutVC.matchedRoute = matchedRoute
        titleLayoutVC.parentLayoutViewController = parent
//        titleLayoutVC.titleLayout = self
//        titleLayoutVC.store = store
        
        return titleLayoutVC
        
    }

}
