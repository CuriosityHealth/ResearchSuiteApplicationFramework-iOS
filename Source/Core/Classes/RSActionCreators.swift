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
    
    public static func addStateValuesFromFile(fileName: String, inDirectory: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return { state, store in
            
            guard let json = RSHelpers.getJson(forFilename: fileName, inDirectory: inDirectory) as? JSON,
                let stateValues: [RSStateValue] = "state" <~~ json else {
                    return nil
            }
            
            stateValues.map({ (stateValue) -> AddStateValueAction in
                return AddStateValueAction(stateValue: stateValue)
            }).forEach { (action) in
                store.dispatch(action)
            }
            
            
            
            return nil
        }
        
    }
    
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
    
    public static func queueActivity(activityID: String) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return QueueActivityAction(uuid: UUID(), activityID: activityID)
        }
    }
    
    public static func setValueInState(key: String, value: NSObject?) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in

            //do some checks first
            
            guard let stateValueMetadata = RSStateSelectors.getStateValueMetadata(state, for: key) else {
                return nil
            }
            
            guard let value = value else {
                if stateValueMetadata.protected {
                    return SetValueInProtectedStorage(key: key, value: nil)
                }
                else {
                    return SetValueInUnprotectedStorage(key: key, value: nil)
                }
            }
            
            //check to see if value can be converted to specified type
            //value is of type NSObject at this point
            if RSStateValue.typeMatches(type: stateValueMetadata.type, object: value) {
                if stateValueMetadata.protected {
                    return SetValueInProtectedStorage(key: key, value: value)
                }
                else {
                    return SetValueInUnprotectedStorage(key: key, value: value)
                }
            }
            
            return nil
        }
    }

}
