//
//  RSNewDashboardLayout.swift
//  Pods
//
//  Created by James Kizer on 9/16/18.
//

import UIKit
import Gloss


public protocol RSDashboardAdaptor: UICollectionViewDataSource, UICollectionViewDelegate {
    func configure(collectionView: UICollectionView)
}

open class RSNewDashboardLayout: RSBaseLayout, RSLayoutGenerator  {
    
    public static func supportsType(type: String) -> Bool {
        return type == "newDashboard"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager, state: RSState) -> RSLayout? {
        return RSNewDashboardLayout(json: jsonObject)
    }
    
    public let adaptor: String
    
    public let backgroundColorJSON: JSON?
    public let backgroundImage: UIImage?
    
    required public init?(json: JSON) {
        
        guard let adaptor: String = "adaptor" <~~ json else {
            return nil
        }
        
        self.adaptor = adaptor
        
        self.backgroundColorJSON = "backgroundColor" <~~ json
        
        self.backgroundImage = {
            if let imageTitle: String = "backgroundImage" <~~ json {
                return UIImage(named: imageTitle)
            }
            else {
                return nil
            }
        }()

        super.init(json: json)
    }
    
    open override func isEqualTo(_ object: Any) -> Bool {
        
        assertionFailure()
        return false
        
    }
    
    open override func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController {
        
        let bundle = Bundle(for: RSNewDashboardLayoutViewController.self)
        let storyboard: UIStoryboard = UIStoryboard(name: "RSViewControllers", bundle: bundle)
        
        guard let layoutVC = storyboard.instantiateViewController(withIdentifier: "newDashboardLayoutViewController") as? RSNewDashboardLayoutViewController else {
            throw RSLayoutError.cannotInstantiateLayout(layoutIdentifier: self.identifier)
        }
        
        layoutVC.matchedRoute = matchedRoute
        layoutVC.parentLayoutViewController = parent
        
        return layoutVC
        
    }
    
}
