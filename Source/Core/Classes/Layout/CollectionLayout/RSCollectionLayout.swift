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
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager, state: RSState) -> RSLayout? {
        return RSCollectionLayout(json: jsonObject)
    }
    
//    public let dataSource: RSCollectionDataSourceDescriptor
    public let datapointClasses: [RSDatapointClass]
    
    public let backgroundColorJSON: JSON?
    public let backgroundImage: UIImage?
    
    required public init?(json: JSON) {
        
        guard let datapointClassesJSON: [JSON] = "datapointClasses" <~~ json else {
                return nil
        }
        
//        self.dataSource = dataSource
        self.datapointClasses = datapointClassesJSON.compactMap({ RSDatapointClass(json: $0) })
        
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
        
        let bundle = Bundle(for: RSCollectionLayout.self)
        let storyboard: UIStoryboard = UIStoryboard(name: "RSViewControllers", bundle: bundle)
        
        guard let collectionLayoutVC = storyboard.instantiateViewController(withIdentifier: "collectionLayoutViewController") as? RSCollectionLayoutViewController else {
            throw RSLayoutError.cannotInstantiateLayout(layoutIdentifier: self.identifier)
        }

        collectionLayoutVC.matchedRoute = matchedRoute
        collectionLayoutVC.parentLayoutViewController = parent
        
        return collectionLayoutVC
        
    }
    
}
