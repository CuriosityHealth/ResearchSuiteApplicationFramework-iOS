//
//  RSCalendarLayout.swift
//  Pods
//
//  Created by James Kizer on 5/18/18.
//

import UIKit
import Gloss


public struct RSCalendarAppearance: JSONDecodable {
    
    public let defaultEventColor: JSON?
    public let headerColor: JSON?
    
    public init?(json: JSON) {
        self.defaultEventColor = "defaultEventColor" <~~ json
        self.headerColor = "headerColor" <~~ json
    }
    
}

open class RSCalendarLayout: RSBaseLayout, RSLayoutGenerator  {
    
    public enum CalendarScope: String {
        case alwaysExpanded = "alwaysExpanded"
        case alwaysCollapsed = "alwaysCollapsed"
        case configurable = "configurable"
    }
    
    public static func supportsType(type: String) -> Bool {
        return type == "calendar"
    }
    
    public static func generate(jsonObject: JSON, layoutManager: RSLayoutManager, state: RSState) -> RSLayout? {
        return RSCalendarLayout(json: jsonObject)
    }
    
//    open let dataSource: RSCollectionDataSourceDescriptor
    open let filterOptions: JSON?
    open let datapointClasses: [RSDatapointClass]
    open let calendarScope: CalendarScope
    open let calendarAppearance: RSCalendarAppearance?
    
    public let backgroundColorJSON: JSON?
    public let backgroundImage: UIImage?
    
    required public init?(json: JSON) {
        
        guard let datapointClassesJSON: [JSON] = "datapointClasses" <~~ json else {
                return nil
        }
        
//        self.dataSource = dataSource
        self.datapointClasses = datapointClassesJSON.compactMap({ RSDatapointClass(json: $0) })
        self.filterOptions = "filterOptions" <~~ json
        if let calendarScopeString: String = "calendarScope" <~~ json,
            let calendarScope = CalendarScope(rawValue: calendarScopeString) {
            self.calendarScope = calendarScope
        }
        else {
            self.calendarScope = .configurable
        }
        
        self.calendarAppearance = "calendarAppearance" <~~ json
        
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
