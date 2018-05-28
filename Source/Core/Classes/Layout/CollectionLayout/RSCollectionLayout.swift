//
//  RSCollectionLayout.swift
//  Pods
//
//  Created by James Kizer on 5/18/18.
//

import UIKit
import Gloss

open class RSCollectionLayout: RSBaseLayout, RSLayoutGenerator {
    
    public static func supportsType(type: String) -> Bool {
        return type == "collection"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager) -> RSLayout? {
        return RSCollectionLayout(json: jsonObject)
    }
    
//    open let dataSource: RSCollectionDataSourceDescriptor
    open let datapointClasses: [RSDatapointClass]
    
    required public init?(json: JSON) {
        
        guard let datapointClassesJSON: [JSON] = "datapointClasses" <~~ json else {
                return nil
        }
        
//        self.dataSource = dataSource
        self.datapointClasses = datapointClassesJSON.compactMap({ RSDatapointClass(json: $0) })
        
        super.init(json: json)
    }
    
    open override func isEqualTo(_ object: Any) -> Bool {
        
        assertionFailure()
        return false
        
    }
    
    open override func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController {
        
        let bundle = Bundle(for: RSCollectionLayout.self)
        let storyboard: UIStoryboard = UIStoryboard(name: "RSViewControllers", bundle: bundle)
        
        guard let collectionLayoutVC = storyboard.instantiateViewController(withIdentifier: "collectionLayoutViewController") as? RSCollectionLayoutViewController else {
            throw RSLayoutError.cannotInstantiateLayout(layoutIdentifier: self.identifier)
        }
        
//        let layout = UICollectionViewFlowLayout()
//        let collectionLayoutVC = RSCollectionLayoutViewController(collectionViewLayout: layout)
        
//        guard let collectionLayoutVC = storyboard.instantiateViewController(withIdentifier: "collectionLayoutViewController") as? RSCollectionLayoutViewController else {
//            throw RSLayoutError.cannotInstantiateLayout(layoutIdentifier: self.identifier)
//        }
        
        collectionLayoutVC.matchedRoute = matchedRoute
        collectionLayoutVC.parentLayoutViewController = parent
        
        return collectionLayoutVC
        
    }
    
}
