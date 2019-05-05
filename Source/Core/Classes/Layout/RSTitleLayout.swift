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
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager, state: RSState) -> RSLayout? {
        return RSTitleLayout(json: jsonObject)
    }
    
    
    public let title: String?
    public let titleJSON: JSON?
    public let titleFontJSON: JSON?
    public let image: UIImage?
    public let button: RSLayoutButton?
    
    //theme
    public let titleTextColorJSON: JSON?
    public let backgroundColorJSON: JSON?
    public let backgroundImage: UIImage?
    public let titleToImageViewSpace: CGFloat?
    
    
    
    
    required public init?(json: JSON) {

        if let title: String = "title" <~~ json {
            self.title = title
            self.titleJSON = nil
        }
        else if let title: JSON = "title" <~~ json {
            self.titleJSON = title
            self.title = nil
        }
        else {
            self.title = nil
            self.titleJSON = nil
        }
        
        self.titleFontJSON = "titleFont" <~~ json
        
        self.image = {
            if let imageTitle: String = "image" <~~ json {
                return UIImage(named: imageTitle)
            }
            else {
                return nil
            }
        }()
        
        self.button = "button" <~~ json
        self.titleTextColorJSON = "titleTextColor" <~~ json
        self.backgroundColorJSON = "backgroundColor" <~~ json
        
        self.backgroundImage = {
            if let imageTitle: String = "backgroundImage" <~~ json {
                return UIImage(named: imageTitle)
            }
            else {
                return nil
            }
        }()
        
        self.titleToImageViewSpace = "titleToImageViewSpace" <~~ json
        
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
