//
//  RSCalendarLayout.swift
//  Pods
//
//  Created by James Kizer on 5/18/18.
//

import UIKit
import Gloss

//open class RSCalendarDatapointClass: RSDatapointClass {
//
//    open let calendarAppearance: JSON
//
//    public required init?(json: JSON) {
//
//        guard let calendarAppearance: JSON = "calendarAppearance" <~~ json else {
//            return nil
//        }
//
//        self.calendarAppearance = calendarAppearance
//        super.init(json: json)
//
//    }
//
//}

open class RSCalendarLayout: RSBaseLayout, RSLayoutGenerator  {
    
    public static func supportsType(type: String) -> Bool {
        return type == "calendar"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager) -> RSLayout? {
        return RSCalendarLayout(json: jsonObject)
    }
    
//    open let dataSource: RSCollectionDataSourceDescriptor
    open let filterOptions: JSON?
    open let datapointClasses: [RSDatapointClass]
    
    required public init?(json: JSON) {
        
        guard let datapointClassesJSON: [JSON] = "datapointClasses" <~~ json else {
                return nil
        }
        
//        self.dataSource = dataSource
        self.datapointClasses = datapointClassesJSON.compactMap({ RSDatapointClass(json: $0) })
        self.filterOptions = "filterOptions" <~~ json
        
        super.init(json: json)
    }
    
    open override func isEqualTo(_ object: Any) -> Bool {
        
        assertionFailure()
        return false
        
    }
    
    open override func instantiateViewController(parent: RSLayoutViewController, matchedRoute: RSMatchedRoute) throws -> RSLayoutViewController {
        
        let bundle = Bundle(for: RSCalendarLayout.self)
        let storyboard: UIStoryboard = UIStoryboard(name: "RSViewControllers", bundle: bundle)
        
        guard let layoutVC = storyboard.instantiateViewController(withIdentifier: "calendarLayoutViewController") as? RSCalendarLayoutViewController else {
            throw RSLayoutError.cannotInstantiateLayout(layoutIdentifier: self.identifier)
        }
        
        layoutVC.matchedRoute = matchedRoute
        layoutVC.parentLayoutViewController = parent
        
        return layoutVC
        
    }
    
}
