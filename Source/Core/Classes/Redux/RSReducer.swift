//
//  RSReducer.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ReSwift
import ResearchKit

public class RSReducer: NSObject {
    
    public static let reducer = CombinedReducer([
        ActivityReducer(),
        MeasureReducer(),
        StateValueReducer(),
        LayoutReducer(),
        RouteReducer(),
        PresentationReducer(),
        ResultsProcessorReducer(),
        AppConfigurationReducer(),
        NotificationReducer(),
        LocationReducer()
    ])
    
    
    
    final class ActivityReducer: Reducer {
        
        open func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case let addActivityAction as AddActivityAction:
                
                let activity = addActivityAction.activity
                var newActivityMap = state.activityMap
                newActivityMap[activity.identifier] = activity
                return RSState.newState(fromState: state, activityMap: newActivityMap)
                
            case let queueActivityAction as QueueActivityAction:
                
                let pair = (queueActivityAction.uuid, queueActivityAction.activityID)
                let newActivityQueue = state.activityQueue + [pair]
                return RSState.newState(fromState: state, activityQueue: newActivityQueue)
                
            case let dequeueActivityAction as DequeueActivityAction:
                
                let newActivityQueue = state.activityQueue.filter { $0.0 != dequeueActivityAction.uuid }
                return RSState.newState(fromState: state, activityQueue: newActivityQueue)
                
            case _ as FlushActivityQueue:
                return RSState.newState(fromState: state, activityQueue: [])
                
//            case let setPresentedActivityAction as SetPresentedActivityAction:
//                
//                let pair = (setPresentedActivityAction.uuid, setPresentedActivityAction.activityID)
//                let newActivityQueue = state.activityQueue.filter { $0.0 != setPresentedActivityAction.uuid }
//                return RSState.newState(fromState: state, activityQueue: newActivityQueue, presentedActivity: pair)
//
//            case let _ as ClearPresentedActivityAction:
//            
//                return RSState.newState(fromState: state, presentedActivity: nil as (UUID, String)?)

            default:
                return state
            }
            
        }
        
    }
    
    final class MeasureReducer: Reducer {
        
        open func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case let addMeasureAction as AddMeasureAction:
                
                let measure = addMeasureAction.measure
                var newMeasureMap = state.measureMap
                newMeasureMap[measure.identifier] = measure
                return RSState.newState(fromState: state, measureMap: newMeasureMap)
                
            default:
                return state
            }
            
        }
    }
    
    final class StateValueReducer: Reducer {
        
        open func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case let addStateValueAction as AddStateValueAction:
                
                let stateValue = addStateValueAction.stateValue
                var newStateValueMap = state.stateValueMap
                newStateValueMap[stateValue.identifier] = stateValue
                return RSState.newState(fromState: state, stateValueMap: newStateValueMap)
                
            case let addConstantValueAction as AddConstantValueAction:
                
                let constantValue = addConstantValueAction.constantValue
                var newConstantsMap = state.constantsMap
                newConstantsMap[constantValue.identifier] = constantValue
                return RSState.newState(fromState: state, constantsMap: newConstantsMap)
                
            case let addFunctionValueAction as AddFunctionValueAction:
                
                let functionValue = addFunctionValueAction.functionValue
                var newMap = state.functionsMap
                newMap[functionValue.identifier] = functionValue
                return RSState.newState(fromState: state, functionsMap: newMap)
                
            case let action as SetValueInState:
                
                var stateDict: [String: NSObject] = state.applicationState
                
                let key = action.key
                
                if let value = action.value,
                    !(value is NSNull) {
                    stateDict[key] = value
                }
                else {
                    stateDict.removeValue(forKey: key)
                }
                
                var hasSetValueDict: [String: NSObject] = state.stateValueHasBeenSet
                hasSetValueDict[key] = NSNumber(booleanLiteral: true)
                
                return RSState.newState(
                    fromState: state,
                    applicationState: stateDict,
                    stateValueHasBeenSet: hasSetValueDict
                )
                
            case let action as ResetValueInState:
                
                var stateDict: [String: NSObject] = state.applicationState
                
                let key = action.key
                stateDict.removeValue(forKey: key)
                
                var hasSetValueDict: [String: NSObject] = state.stateValueHasBeenSet
                hasSetValueDict[key] = NSNumber(booleanLiteral: false)
                
                return RSState.newState(
                    fromState: state,
                    applicationState: stateDict,
                    stateValueHasBeenSet: hasSetValueDict
                )
                
            case let registerFunctionAction as RegisterFunctionAction:
                
                guard let functionValue = state.functionsMap[registerFunctionAction.identifier] else {
                    return state
                }

                //note that functionValue.with returns a new object
                let newFunctionValue = functionValue.with(function: registerFunctionAction.function)
                var newMap = state.functionsMap
                newMap[functionValue.identifier] = newFunctionValue
                return RSState.newState(fromState: state, functionsMap: newMap)
                
            case let unregisterFunctionAction as UnregisterFunctionAction:
                
                guard let functionValue = state.functionsMap[unregisterFunctionAction.identifier] else {
                    return state
                }
                
                let newFunctionValue = functionValue.with(function: nil)
                var newMap = state.functionsMap
                newMap[functionValue.identifier] = newFunctionValue
                return RSState.newState(fromState: state, functionsMap: newMap)
                
            default:
                return state
            }
            
        }
    }
    
    final class LayoutReducer: Reducer {
        
        open func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case let action as AddLayoutAction:
                
                let layout = action.layout
                var newMap = state.layoutMap
                newMap[layout.identifier] = layout
                return RSState.newState(fromState: state, layoutMap: newMap)
                
            default:
                return state
            }
            
        }
    }
    
//    public struct ChangeRouteRequest: Action {
//        let route: RSRoute
//    }
//    
//    public struct ChangeRouteSuccess: Action {
//        let route: RSRoute
//    }
//    
//    public struct ChangeRouteFailure: Action {
//        let route: RSRoute
//    }
//    
    final class RouteReducer: Reducer {
        
        open func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case let action as AddRouteAction:
                
                let route = action.route
                var newMap = state.routeMap
                newMap[route.identifier] = route
                let newIdentifierList = state.routeIdentifiers.filter { $0 != route.identifier}  + [route.identifier]
                return RSState.newState(fromState: state, routeMap: newMap, routeIdentifiers: newIdentifierList)
                
            case _ as ChangeRouteRequest:
                return RSState.newState(fromState: state, isRouting: true)
                
            case let action as ChangeRouteSuccess:
                return RSState.newState(fromState: state, isRouting: false, currentRoute: action.route)
                
            case _ as ChangeRouteFailure:
                return RSState.newState(fromState: state, isRouting: false)
                
            default:
                return state
            }
            
        }
    }
    
    final class PresentationReducer: Reducer  {
        
        open func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case _ as PresentActivityRequest:
                return RSState.newState(fromState: state, isPresenting: true)
                
            case let action as PresentActivitySuccess:
                let pair = (action.uuid, action.activityID, action.presentationTime)
                let newActivityQueue = state.activityQueue.filter { $0.0 != action.uuid }
                return RSState.newState(fromState: state, activityQueue: newActivityQueue, isPresenting: false, presentedActivity: pair)
                
            case let action as PresentActivityFailure:
                let newActivityQueue = state.activityQueue.filter { $0.0 != action.uuid }
                return RSState.newState(fromState: state, activityQueue: newActivityQueue, isPresenting: false)
                
            case _ as DismissActivityRequest:
                return RSState.newState(fromState: state, isDismissing: true)
                
            case _ as DismissActivitySuccess:
                return RSState.newState(fromState: state, isDismissing: false, presentedActivity: nil as (UUID, String, Date)?)
                
            case _ as DismissActivityFailure:
                return RSState.newState(fromState: state, isDismissing: false)
                
            case _ as PresentPasscodeRequest:
                return RSState.newState(fromState: state, isPresentingPasscode: true)
                
            case let action as PresentPasscodeSuccess:
                return RSState.newState(fromState: state, isPresentingPasscode: false, passcodeViewController: action.passcodeViewController)
                
            case _ as PresentPasscodeFailure:
                return RSState.newState(fromState: state, isPresentingPasscode: false)
                
            case _ as DismissPasscodeRequest:
                return RSState.newState(fromState: state, isDismissingPasscode: true)
                
            case _ as DismissPasscodeSuccess:
                return RSState.newState(fromState: state, passcodeViewController: nil as ORKPasscodeViewController?, isDismissingPasscode: false)
                
            case _ as DismissPasscodeFailure:
                return RSState.newState(fromState: state, isDismissingPasscode: false)

            default:
                return state
            }
            
        }
        
    }
    
    final class ResultsProcessorReducer: Reducer {
        open func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case let action as RegisterResultsProcessorBackEndAction:

                var newMap = state.resultsProcessorBackEndMap
                newMap[action.identifier] = action.backEnd
                return RSState.newState(fromState: state, resultsProcessorBackEndMap: newMap)
                
            case let action as UnregisterResultsProcessorBackEndAction:
                
                var newMap = state.resultsProcessorBackEndMap
                newMap.removeValue(forKey: action.identifier)
                return RSState.newState(fromState: state, resultsProcessorBackEndMap: newMap)
                
            default:
                return state
            }
            
        }
    }
    
    final class AppConfigurationReducer: Reducer {
        open func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case _ as CompleteConfiguration:
                return RSState.newState(fromState: state, configurationCompleted: true)
                
            case _ as SignOutRequest:
                return RSState.newState(fromState: state, signOutRequested: true)
                
            case let action as SetPreventSleep:
                return RSState.newState(fromState: state, preventSleep: action.preventSleep)
                
            default:
                return state
            }
            
        }
    }
    
    final class NotificationReducer: Reducer {
        open func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case _ as FetchPendingNotificationsRequest:
                return RSState.newState(fromState: state, isFetchingNotifications: true)
                
            case let successAction as FetchPendingNotificationsSuccess:
                return RSState.newState(fromState: state, pendingNotifications: successAction.pendingNotifications, isFetchingNotifications: false, lastFetchTime: successAction.fetchTime)
                
            case _ as FetchPendingNotificationsFailure:
                return RSState.newState(fromState: state, isFetchingNotifications: false)
                
            case let addNotificationAction as AddNotificationAction:
                
                let notification = addNotificationAction.notification
                return RSState.newState(fromState: state, notifications: state.notifications + [notification])
                
            default:
                return state
            }
            
        }
    }
    
    final class LocationReducer: Reducer {
        open func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case _ as FetchCurrentLocationRequest:
                return RSState.newState(fromState: state, isFetchingLocation: true)
                
            case _ as FetchCurrentLocationSuccess:
                return RSState.newState(fromState: state, isFetchingLocation: false)
                
            case _ as FetchCurrentLocationFailure:
                return RSState.newState(fromState: state, isFetchingLocation: false)
                
            case _ as UpdateLocationAuthorizationStatusRequest:
                return RSState.newState(fromState: state, isRequestingLocationAuthorization: true)
                
            case let action as UpdateLocationAuthorizationStatusSuccess:
                return RSState.newState(fromState: state, isRequestingLocationAuthorization: false, locationAuthorizationStatus: action.status)
                
            case _ as UpdateLocationAuthorizationStatusFailure:
                return RSState.newState(fromState: state, isRequestingLocationAuthorization: false)
                
            case let action as SetLocationMonitoringEnabled:
                return RSState.newState(fromState: state, isLocationMonitoringEnabled: action.enabled)
                
            default:
                return state
            }
            
        }
    }
}
