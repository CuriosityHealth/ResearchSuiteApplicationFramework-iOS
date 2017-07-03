//
//  RSReducer.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ReSwift

public class RSReducer: NSObject {
    
    public static let reducer = CombinedReducer([
        ActivityReducer(),
        MeasureReducer(),
        StateValueReducer(),
        LayoutReducer(),
        RouteReducer()
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
                
            case let setPresentedActivityAction as SetPresentedActivityAction:
                
                let pair = (setPresentedActivityAction.uuid, setPresentedActivityAction.activityID)
                let newActivityQueue = state.activityQueue.filter { $0.0 != setPresentedActivityAction.uuid }
                return RSState.newState(fromState: state, activityQueue: newActivityQueue, presentedActivity: pair)
                
            case let _ as ClearPresentedActivityAction:
            
                return RSState.newState(fromState: state, presentedActivity: nil as (UUID, String)?)

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
                
            case let setValueAction as SetValueInProtectedStorage:
                
                var stateDict: [String: NSObject] = state.protectedState
                
                let key = setValueAction.key
                
                if let value = setValueAction.value {
                    stateDict[key] = value
                }
                else {
                    stateDict.removeValue(forKey: key)
                }
                
                var hasSetValueDict: [String: NSObject] = state.stateValueHasBeenSet
                hasSetValueDict[key] = NSNumber(booleanLiteral: true)
                
                return RSState.newState(
                    fromState: state,
                    protectedState: stateDict,
                    stateValueHasBeenSet: hasSetValueDict
                )
                
            case let setValueAction as SetValueInUnprotectedStorage:
                
                var stateDict: [String: NSObject] = state.unprotectedState
                
                let key = setValueAction.key
                
                if let value = setValueAction.value {
                    stateDict[key] = value
                }
                else {
                    stateDict.removeValue(forKey: key)
                }
                
                var hasSetValueDict: [String: NSObject] = state.stateValueHasBeenSet
                hasSetValueDict[key] = NSNumber(booleanLiteral: true)
                
                return RSState.newState(
                    fromState: state,
                    unprotectedState: stateDict,
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
    
    final class RouteReducer: Reducer {
        
        open func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case let action as AddRouteAction:
                
                let route = action.route
                var newMap = state.routeMap
                newMap[route.identifier] = route
                return RSState.newState(fromState: state, routeMap: newMap)
                
            default:
                return state
            }
            
        }
    }
}
