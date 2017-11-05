//
//  RSStateSelectors.swift
//  Pods
//
//  Created by James Kizer on 6/23/17.
//
//

import UIKit
import ResearchSuiteResultsProcessor
import ResearchKit

public class RSStateSelectors: NSObject {
    
    public static func getApplicationState(_ state: RSState) -> [String : NSObject] {
        return state.applicationState
    }
    
    public static func getValueInApplicationState(_ state: RSState) -> (String) -> NSSecureCoding? {
        return { key in
            return state.applicationState[key] as? NSSecureCoding
        }
    }
    
//    public static func getProtectedStorage(_ state: RSState) -> [String : NSObject] {
//        return state.protectedState
//    }
//    
//    public static func getValueInProtectedStorage(_ state: RSState) -> (String) -> NSSecureCoding? {
//        return { key in
//            return state.protectedState[key] as? NSSecureCoding
//        }
//    }
//    
//    public static func getUnprotectedStorage(_ state: RSState) -> [String : NSObject] {
//        return state.unprotectedState
//    }
//    
//    public static func getValueInUnprotectedStorage(_ state: RSState) -> (String) -> NSSecureCoding? {
//        return { key in
//            return state.unprotectedState[key] as? NSSecureCoding
//        }
//    }
    
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
    
    public static func getAllStateValueMetadata(_ state: RSState) -> [RSStateValue] {
        return Array(state.stateValueMap.values)
    }
    
    public static func getStateValueMetadataForStateManager(_ state: RSState, stateManagerID: String) -> [RSStateValue] {
        return Array(state.stateValueMap.values.filter { $0.stateManager == stateManagerID })
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
            return  RSValueConvertible(value: state.applicationState[key])
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
    
    public static func getQueuedActivities(_ state: RSState) -> [(UUID, String)] {
        return state.activityQueue
    }
    
    public static func isPresenting(_ state: RSState) -> Bool {
        return state.isPresenting
    }
    
    public static func isDismissing(_ state: RSState) -> Bool {
        return state.isDismissing
    }
    
    public static func presentedActivity(_ state: RSState) -> (UUID, String, Date)? {
        return state.presentedActivity
    }
    
    public static func shouldPresent(_ state: RSState) -> Bool {
        return (state.activityQueue.first != nil) &&
            (!state.isPresenting) &&
            (state.presentedActivity == nil) &&
            (!state.isDismissing) &&
            (!state.isRouting) &&
            (state.currentRoute != nil) &&
            (state.configurationCompleted)
    }

    public static func isRouting(_ state: RSState) -> Bool {
        return state.isRouting
    }
    
    public static func currentRoute(_ state: RSState) -> RSRoute? {
        return state.currentRoute
    }
    
    public static func shouldRoute(_ state: RSState, route: RSRoute) -> Bool {
        
        let shouldRoute = !RSStateSelectors.isRouting(state) &&
            RSStateSelectors.currentRoute(state) != route &&
            !RSStateSelectors.isPresenting(state) &&
            RSStateSelectors.presentedActivity(state) == nil &&
            !RSStateSelectors.isDismissing(state)
        
        return shouldRoute
    }
    
    public static func getResultsProcessorBackEnd(_ state: RSState, for identifier: String) -> RSRPBackEnd? {
        return state.resultsProcessorBackEndMap[identifier]
    }
    
    public static func isConfigurationCompleted(_ state: RSState) -> Bool {
        return state.configurationCompleted
    }
    
    public static func shouldShowPasscode(_ state: RSState) -> Bool {
        return !RSStateSelectors.isPasscodePresented(state) &&
            ORKPasscodeViewController.isPasscodeStoredInKeychain()
    }
    
    public static func isPasscodePresented(_ state: RSState) -> Bool {
        return state.passcodeViewController != nil
    }
    
    public static func isPresentingPasscode(_ state: RSState) -> Bool {
        return state.isPresentingPasscode
    }
    
    public static func isDismissingPasscode(_ state: RSState) -> Bool {
        return state.isDismissingPasscode
    }
    
    public static func passcodeViewController(_ state: RSState) -> ORKPasscodeViewController? {
        return state.passcodeViewController
    }

}
