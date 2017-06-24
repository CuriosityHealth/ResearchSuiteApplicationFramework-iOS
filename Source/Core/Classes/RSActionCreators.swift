//
//  RSActionCreators.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ReSwift
import Gloss

public class RSActionCreators: NSObject {
    
    public static func addMeasuresFromFile(fileName: String, inDirectory: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return { state, store in
            
            guard let json = RSHelpers.getJson(forFilename: fileName, inDirectory: inDirectory) as? JSON,
                let measures: [RSMeasure] = "measures" <~~ json else {
                    return nil
            }
            
            measures.map({ (measure) -> AddMeasureAction in
                return AddMeasureAction(measure: measure)
            }).forEach { (action) in
                store.dispatch(action)
            }
            
            return nil
        }
        
    }
    
    public static func addActivitiesFromFile(fileName: String, inDirectory: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return { state, store in
            
            guard let json = RSHelpers.getJson(forFilename: fileName, inDirectory: inDirectory) as? JSON,
                let activities: [RSActivity] = "activities" <~~ json else {
                    return nil
            }
            
            activities.map({ (activity) -> AddActivityAction in
                return AddActivityAction(activity: activity)
            }).forEach { (action) in
                store.dispatch(action)
            }
            
            return nil
        }
        
    }

}
