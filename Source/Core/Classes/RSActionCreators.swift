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
    
    
    //loads json from (fileName, directory)
    //uses selector to select the array we want to process
    //converts each JSON element in array to an object
    //converts each object into an action
    //dispatches each action
    private static func addArrayOfObjectsFromFile<T>(fileName: String, inDirectory: String? = nil, selector: @escaping (JSON) -> [JSON]?, flatMapFunc: @escaping (JSON) -> T?, mapFunc: @escaping (T) -> Action) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            guard let json = RSHelpers.getJson(forFilename: fileName, inDirectory: inDirectory) as? JSON,
                let jsonArray = selector(json) else {
                    return nil
            }
            
            jsonArray
                .flatMap(flatMapFunc)
                .map(mapFunc)
                .forEach { store.dispatch($0) }
            
            return nil
        }
    }
    
    public static func addStateValuesFromFile(fileName: String, inDirectory: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {

        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            selector: { "state" <~~ $0 },
            flatMapFunc: { RSStateValue(json: $0) },
            mapFunc: { AddStateValueAction(stateValue: $0) }
        )
        
    }
    
    public static func addConstantsFromFile(fileName: String, inDirectory: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            selector: { "constants" <~~ $0 },
            flatMapFunc: { RSConstantValue(json: $0) },
            mapFunc: { AddConstantValueAction(constantValue: $0) }
        )
        
    }
    
    public static func addFunctionsFromFile(fileName: String, inDirectory: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {

        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            selector: { "functions" <~~ $0 },
            flatMapFunc: { RSFunctionValue(json: $0) },
            mapFunc: { AddFunctionValueAction(functionValue: $0) }
        )
        
    }
    
    public static func addMeasuresFromFile(fileName: String, inDirectory: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            selector: { "measures" <~~ $0 },
            flatMapFunc: { RSMeasure(json: $0) },
            mapFunc: { AddMeasureAction(measure: $0) }
        )
        
    }
    
    public static func addActivitiesFromFile(fileName: String, inDirectory: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            selector: { "activities" <~~ $0 },
            flatMapFunc: { RSActivity(json: $0) },
            mapFunc: { AddActivityAction(activity: $0) }
        )
        
    }
    
    public static func queueActivity(activityID: String) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return QueueActivityAction(uuid: UUID(), activityID: activityID)
        }
    }
    
    public static func presentedActivity(uuid: UUID, activityID: String) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return SetPresentedActivityAction(uuid: uuid, activityID: activityID)
        }
    }
    
    public static func dismissedActivity(uuid: UUID, activityID: String) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return ClearPresentedActivityAction()
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
    
    public static func registerFunction(identifier: String, function: @escaping () -> AnyObject?) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return RegisterFunctionAction(identifier: identifier, function: function)
        }
    }
    
    public static func unregisterFunction(identifier: String) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return UnregisterFunctionAction(identifier: identifier)
        }
    }

}
