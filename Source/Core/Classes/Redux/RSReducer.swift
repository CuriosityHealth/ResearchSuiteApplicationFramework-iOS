//
//  RSReducer.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
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
//        RouteReducer(),
        PathReducer(),
        PresentationReducer(),
        DataFlowReducer(),
        AppConfigurationReducer(),
        NotificationReducer(),
        LocationReducer(),
        SchedulerReducer()
    ])
    
    
    
    final class ActivityReducer: Reducer {
        
        public func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case let addActivityAction as AddActivityAction:
                
                let activity = addActivityAction.activity
                var newActivityMap = state.activityMap
                newActivityMap[activity.identifier] = activity
                return RSState.newState(fromState: state, activityMap: newActivityMap)
                
            case let queueActivityAction as QueueActivityAction:
                
                let pair = (queueActivityAction.uuid, queueActivityAction.activityID, queueActivityAction.context, queueActivityAction.onCompletionActions)
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
        
        public func handleAction(action: Action, state: RSState?) -> RSState {
            
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
        
        public func handleAction(action: Action, state: RSState?) -> RSState {
            
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
                
            case let action as AddDefinedAction:
                
                let definedAction = action.definedAction
                var newMap = state.definedActionsMap
                newMap[definedAction.identifier] = definedAction
                return RSState.newState(fromState: state, definedActionsMap: newMap)
                
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
                
                assert(state.functionsMap[registerFunctionAction.identifier] == nil || state.functionsMap[registerFunctionAction.identifier] is RSDefinedFunctionValue)
                guard let functionValue = state.functionsMap[registerFunctionAction.identifier] as? RSDefinedFunctionValue else {
                    return state
                }

                //note that functionValue.with returns a new object
                let newFunctionValue = functionValue.with(function: registerFunctionAction.function)
                var newMap = state.functionsMap
                newMap[functionValue.identifier] = newFunctionValue
                return RSState.newState(fromState: state, functionsMap: newMap)
                
            case let unregisterFunctionAction as UnregisterFunctionAction:
                
                assert(state.functionsMap[unregisterFunctionAction.identifier] is RSDefinedFunctionValue)
                guard let functionValue = state.functionsMap[unregisterFunctionAction.identifier] as? RSDefinedFunctionValue else {
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
        
        public func handleAction(action: Action, state: RSState?) -> RSState {
            
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
        
        public func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case let action as AddRouteAction:
                
                let route = action.route
                var newMap = state.routeMap
                newMap[route.identifier] = route
                let newIdentifierList = state.routeIdentifiers.filter { $0 != route.identifier}  + [route.identifier]
                return RSState.newState(fromState: state, routeMap: newMap, routeIdentifiers: newIdentifierList)
                
//            case _ as ChangeRouteRequest:
//                return RSState.newState(fromState: state, isRouting: true)
//
//            case let action as ChangeRouteSuccess:
//                return RSState.newState(fromState: state, isRouting: false, currentRoute: action.route)
//
//            case _ as ChangeRouteFailure:
//                return RSState.newState(fromState: state, isRouting: false)
                
            default:
                return state
            }
            
        }
    }

    
//    public struct ChangePathRequest: Action {
//        let requestedPath: String
//    }
//
//    public struct RoutingStarted: Action {
//        let requestedPath: String
//    }
//
//    public struct ChangePathSuccess: Action {
//        let requestedPath: String
//        let finalPath: String
//    }
//
//    public struct ChangePathFailure: Action {
//        let requestedPath: String
//        let finalPath: String
//        let error: Error
//    }
    
    final class PathReducer: Reducer {
        public func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
//            case let action as AddRouteAction:
//
//                let route = action.route
//                var newMap = state.routeMap
//                newMap[route.identifier] = route
//                let newIdentifierList = state.routeIdentifiers.filter { $0 != route.identifier}  + [route.identifier]
//                return RSState.newState(fromState: state, routeMap: newMap, routeIdentifiers: newIdentifierList)
//
            case let action as ChangePathRequest:
                let queue = state.pathChangeRequestQueue + [ (action.uuid, action.requestedPath, action.forceReroute) ]
                return RSState.newState(fromState: state, pathChangeRequestQueue: queue)
                
            case _ as RoutingStarted:
                return RSState.newState(fromState: state, isRouting: true)
                
            case let action as ChangePathSuccess:
                let pathHistory = state.pathHistory + [ action.finalPath]
                let queue = state.pathChangeRequestQueue.filter { $0.0 != action.uuid }
                return RSState.newState(fromState: state, isRouting: false, pathHistory: pathHistory, currentPath: action.finalPath, pathChangeRequestQueue: queue)
                
            case let action as ChangePathFailure:
//                assertionFailure()
                let queue = state.pathChangeRequestQueue.filter { $0.0 != action.uuid }
                return RSState.newState(fromState: state, isRouting: false, pathChangeRequestQueue: queue)
                
            default:
                return state
            }
            
        }
    }
    
    
    final class PresentationReducer: Reducer  {
        
        public func handleAction(action: Action, state: RSState?) -> RSState {
            
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
                
            case let action as RequestSetContentHidden:
                return RSState.newState(fromState: state, setContentHiddenRequested: action.hidden)
                
            case _ as SetContentHiddedStarted:
                return RSState.newState(fromState: state, setContentHiddenRequested: nil as Bool?, settingContentHidden: true)
                
            case let action as SetContentHiddedCompleted:
                return RSState.newState(fromState: state, settingContentHidden: false, contentHidden: action.hidden)
                
            case _ as RequestPasscode:
                return RSState.newState(fromState: state, passcodeRequested: true)
                
            case _ as PresentPasscodeRequest:
                return RSState.newState(fromState: state, passcodeRequested: false, isPresentingPasscode: true )
                
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
    
    final class DataFlowReducer: Reducer {
        public func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case let action as RegisterDataSourceAction:
                
                var newMap = state.dataSourceMap
                newMap[action.identifier] = action.dataSource
                return RSState.newState(fromState: state, dataSourceMap: newMap)
                
            case let action as UnregisterDataSourceAction:
                
                var newMap = state.dataSourceMap
                newMap.removeValue(forKey: action.identifier)
                return RSState.newState(fromState: state, dataSourceMap: newMap)
                
            case let action as RegisterDataSinkAction:
                
                var newMap = state.dataSinkMap
                newMap[action.identifier] = action.dataSink
                return RSState.newState(fromState: state, dataSinkMap: newMap)
                
            case let action as UnregisterDataSourceAction:
                
                var newMap = state.dataSinkMap
                newMap.removeValue(forKey: action.identifier)
                return RSState.newState(fromState: state, dataSinkMap: newMap)
                
//            case let action as RegisterResultsProcessorBackEndAction:
//
//                var newMap = state.resultsProcessorBackEndMap
//                newMap[action.identifier] = action.backEnd
//                return RSState.newState(fromState: state, resultsProcessorBackEndMap: newMap)
//
//            case let action as UnregisterResultsProcessorBackEndAction:
//
//                var newMap = state.resultsProcessorBackEndMap
//                newMap.removeValue(forKey: action.identifier)
//                return RSState.newState(fromState: state, resultsProcessorBackEndMap: newMap)
                
            default:
                return state
            }
            
        }
    }
    
    final class AppConfigurationReducer: Reducer {
        public func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case _ as CompleteConfiguration:
                return RSState.newState(fromState: state, configurationCompleted: true)
                
            case _ as SignOutRequest:
                return RSState.newState(fromState: state, signOutRequested: true)
                
            case _ as ReloadConfigurationRequest:
                return RSState.newState(fromState: state, reloadConfigRequested: true)
                
            case let action as SetPreventSleep:
                return RSState.newState(fromState: state, preventSleep: action.preventSleep)
                
            default:
                return state
            }
            
        }
    }
    
    final class NotificationReducer: Reducer {
        public func handleAction(action: Action, state: RSState?) -> RSState {
            
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
                
            case let removeNotificationAction as RemoveNotificationAction:
                
                let notifications = state.notifications.filter { removeNotificationAction.notificationIdentifier != $0.identifier }
                return RSState.newState(fromState: state, notifications: notifications)
                
            case let updateNotificationAction as UpdateNotificationAction:
                
                let notifications = state.notifications.filter { updateNotificationAction.notification.identifier != $0.identifier } + [updateNotificationAction.notification]
                return RSState.newState(fromState: state, notifications: notifications)
                
            default:
                return state
            }
            
        }
    }
    
    final class LocationReducer: Reducer {
        public func handleAction(action: Action, state: RSState?) -> RSState {
            
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
                
            case let action as SetVisitMonitoringEnabled:
                return RSState.newState(fromState: state, isVisitMonitoringEnabled: action.enabled)
                
            default:
                return state
            }
            
        }
    }
    
    final class SchedulerReducer: Reducer {
        
        public func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case let action as UpdateScheduler:
                
                return RSState.newState(fromState: state, schedulerEventUpdate: action.schedulerEventUpdate)

            default:
                return state
            }
            
        }
    }
}
