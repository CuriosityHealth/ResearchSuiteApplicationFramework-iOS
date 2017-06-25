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
    
    public static func getStateValueMetadata(_ state: RSState, for identifier: String) -> RSStateValue? {
        return state.stateValueMap[identifier]
    }
    
    public static func getValueInStorage(_ state: RSState) -> (String) -> NSSecureCoding? {
        return { key in
            
            guard let stateValueMetadata = state.stateValueMap[key] else {
                return nil
            }
            
            if !(state.stateValueHasBeenSet[key] as? Bool ?? false) {
                return stateValueMetadata.getDefaultValue() as? NSSecureCoding
            }
            else {
                if stateValueMetadata.protected {
                    return state.protectedState[key] as? NSSecureCoding
                }
                else {
                    return state.unprotectedState[key] as? NSSecureCoding
                }
            }
            
        }
    }


}
