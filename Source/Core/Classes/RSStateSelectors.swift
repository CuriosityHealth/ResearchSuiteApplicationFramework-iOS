//
//  RSStateSelectors.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit

public class RSStateSelectors: NSObject {
    
    public static func getProtectedStorage(_ state: RSState) -> [String : NSObject] {
        return state.protectedState
    }
    
    public static func getValueInProtectedStorage(_ state: RSState) -> (String) -> NSSecureCoding? {
        return { key in
            return state.protectedState[key] as? NSSecureCoding
        }
    }
    
    public static func getUnprotectedStorage(_ state: RSState) -> [String : NSObject] {
        return state.unprotectedState
    }
    
    public static func getValueInUnprotectedStorage(_ state: RSState) -> (String) -> NSSecureCoding? {
        return { key in
            return state.unprotectedState[key] as? NSSecureCoding
        }
    }
    
    public static func getStateValueHasBeenSet(_ state: RSState) -> [String : NSObject] {
        return state.stateValueHasBeenSet
    }
    
    public static func hasStateValueBeenSet(_ state: RSState) -> (String) -> Bool {
        return { key in
            return state.stateValueHasBeenSet[key] as? Bool ?? false
        }
    }
    
    public static func measure(_ state: RSState, for identifier: String) -> RSMeasure? {
        return state.measureMap[identifier]
    }
    
    public static func activity(_ state: RSState, for identifier: String) -> RSActivity? {
        return state.activityMap[identifier]
    }
    
    public static func layout(_ state: RSState, for identifier: String) -> RSLayout? {
        return state.layoutMap[identifier]
    }
    
    public static func routes(_ state: RSState) -> [RSRoute] {
        return state.routeIdentifiers.flatMap { state.routeMap[$0] }
    }
    
    public static func getStateValueMetadata(_ state: RSState, for identifier: String) -> RSStateValue? {
        return state.stateValueMap[identifier]
    }
    
    //TODO: The returned closure should probably throw a key error in the future
    public static func getValueInStorage(_ state: RSState, for key: String) -> ValueConvertible? {
        guard let stateValueMetadata = state.stateValueMap[key] else {
            return nil
        }
        
        if !(state.stateValueHasBeenSet[key] as? Bool ?? false) {
            return stateValueMetadata.getDefaultValue()
        }
        else {
            if stateValueMetadata.protected {
                return  RSValueConvertible(value: state.protectedState[key])
            }
            else {
                return RSValueConvertible(value: state.unprotectedState[key])
            }
        }
    }
    
    public static func getConstantValue(_ state: RSState, for identifier: String) -> RSConstantValue? {
        return state.constantsMap[identifier]
    }
    
    public static func getFunctionValue(_ state: RSState, for identifier: String) -> RSFunctionValue? {
        return state.functionsMap[identifier]
    }
    
    public static func getNextActivity(_ state: RSState) -> (UUID, String)? {
        return state.activityQueue.first
    }
    
    public static func isPresenting(_ state: RSState) -> Bool {
        return state.isPresenting
    }
    
    public static func isDismissing(_ state: RSState) -> Bool {
        return state.isDismissing
    }
    
    public static func presentedActivity(_ state: RSState) -> (UUID, String)? {
        return state.presentedActivity
    }
    
    public static func shouldPresent(_ state: RSState) -> Bool {
        return (state.activityQueue.first != nil) &&
            (!state.isPresenting) &&
            (state.presentedActivity == nil) &&
            (!state.isDismissing)
    }


}
