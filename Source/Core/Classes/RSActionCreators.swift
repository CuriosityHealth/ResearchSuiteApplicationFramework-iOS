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
import ResearchKit

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
    
    public static func addLayoutsFromFile(fileName: String, inDirectory: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            selector: { "layouts" <~~ $0 },
            flatMapFunc: { RSLayout(json: $0) },
            mapFunc: { AddLayoutAction(layout: $0) }
        )
        
    }
    
    public static func addRoutesFromFile(fileName: String, inDirectory: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            selector: { "routes" <~~ $0 },
            flatMapFunc: { RSRoute(json: $0) },
            mapFunc: { AddRouteAction(route: $0) }
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
    
    public static func presentActivity(on viewController: UIViewController, activityManager: RSActivityManager) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            //make sure we are not in the middle of routing
            //and there is a valid route
            guard !RSStateSelectors.isRouting(state),
                RSStateSelectors.currentRoute(state) != nil else {
                return nil
            }
            
            //if nothing is presented and there are things to present, then begin presentation on delegate
            guard !RSStateSelectors.isPresenting(state),
                RSStateSelectors.presentedActivity(state) == nil else {
                return nil
            }
            
            guard let firstActivity: (UUID, String) = RSStateSelectors.getNextActivity(state),
                let activity = RSStateSelectors.activity(state, for: firstActivity.1),
                let task = activityManager.taskForActivity(activity: activity, state: state) else {
                    return nil
            }
            
            let taskFinishedHandler: ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ()) = { (taskViewController, reason, error) in
                
                //process on success action
                if reason == ORKTaskViewControllerFinishReason.completed {
                    let taskResult = taskViewController.result
                    RSActionCreators.processOnSuccessActions(activity: activity, taskResult: taskResult, store: store)
                }
                    //process on failure actions
                else {
                    RSActionCreators.processOnFailureActions(activity: activity, store: store)
                }
                
                //process finally actions
                RSActionCreators.processFinallyActions(activity: activity, store: store)
                
                //dismiss view controller
                store.dispatch(RSActionCreators.dismissActivity(firstActivity.0, activity: activity, viewController: viewController, activityManager: activityManager))
                
            }
            
            let taskViewController = RSTaskViewController(activityUUID: firstActivity.0, task: task, taskFinishedHandler: taskFinishedHandler)
            
            let presentRequestAction = PresentActivityRequest(uuid: firstActivity.0, activityID: firstActivity.1)
            store.dispatch(presentRequestAction)
            
            viewController.present(taskViewController, animated: true, completion: {
                
                let presentSuccessAction = PresentActivitySuccess(uuid: firstActivity.0, activityID: firstActivity.1)
                store.dispatch(presentSuccessAction)

            })
            
            return nil
        }
    }
    
    public static func dismissActivity(_ uuid: UUID, activity: RSActivity, viewController: UIViewController, activityManager: RSActivityManager) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            guard !RSStateSelectors.isDismissing(state),
                let presentedActivityPair = RSStateSelectors.presentedActivity(state),
                presentedActivityPair.0 == uuid else {
                    return nil
            }
            
            let dismissRequestAction = DismissActivityRequest(uuid: presentedActivityPair.0, activityID: presentedActivityPair.1)
            store.dispatch(dismissRequestAction)
            
            viewController.dismiss(animated: true, completion: {
                let dismissSuccessAction = DismissActivitySuccess(uuid: presentedActivityPair.0, activityID: presentedActivityPair.1)
                store.dispatch(dismissSuccessAction)
            })
            
            return nil
        }
    }
    
    
    private static func processOnSuccessActions(activity: RSActivity, taskResult: ORKTaskResult, store: Store<RSState>) {
        let onSuccessActionJSON: [JSON] = activity.onCompletion.onSuccessActions
        let context: [String: AnyObject] = ["taskResult": taskResult]
        RSActionManager.processActions(actions: onSuccessActionJSON, context: context, store: store)
    }
    
    private static func processOnFailureActions(activity: RSActivity, store: Store<RSState>) {
        let onFailureActionJSON: [JSON] = activity.onCompletion.onFailureActions
        let context: [String: AnyObject] = [:]
        RSActionManager.processActions(actions: onFailureActionJSON, context: context, store: store)
    }
    
    private static func processFinallyActions(activity: RSActivity, store: Store<RSState>) {
        let finallyActionJSON: [JSON] = activity.onCompletion.finallyActions
        let context: [String: AnyObject] = [:]
        RSActionManager.processActions(actions: finallyActionJSON, context: context, store: store)
    }

    public static func evaluatePredicate(predicate: RSPredicate, state: RSState, context: [String: AnyObject]) -> Bool {
        //construct substitution dictionary
        
        let nsPredicate = NSPredicate.init(format: predicate.format)
        
        guard let substitutionsJSON = predicate.substitutions else {
            return nsPredicate.evaluate(with: nil)
        }
        
        var substitutions: [String: Any] = [:]
        
        substitutionsJSON.forEach({ (key: String, value: JSON) in
            
            if let valueConvertible = RSValueManager.processValue(jsonObject:value, state: state, context: context) {
                
                //so we know this is a valid value convertible (i.e., it's been recognized by the state map)
                //we also want to potentially have a null value substituted
                if let value = valueConvertible.evaluate() {
                    substitutions[key] = value
                }
                else {
                    assertionFailure("Added NSNull support for this type")
                    let nilObject: AnyObject? = nil as AnyObject?
                    substitutions[key] = nilObject as Any
                }
                
            }
            
        })
        
        guard substitutions.count == substitutionsJSON.count else {
            return false
        }
        
        return nsPredicate.evaluate(with: nil, substitutionVariables: substitutions)
        
    }
    
    public static func setRoute(route: RSRoute, layoutManager: RSLayoutManager, delegate: RSRouterDelegate) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            guard !RSStateSelectors.isRouting(state) else {
                    return nil
            }
            
            //also verify that we are not in the middle of presenting a task
            guard !RSStateSelectors.isPresenting(state),
                RSStateSelectors.presentedActivity(state) == nil,
                !RSStateSelectors.isDismissing(state) else {
                    return nil
            }
            
            //if current route is nil, route first route
            //if current route is not first route, route first route
            let currentRoute = RSStateSelectors.currentRoute(state)
            
            if currentRoute == nil ||
                currentRoute!.identifier != route.identifier {
                
                let routeRequestAction = ChangeRouteRequest(route: route)
                store.dispatch(routeRequestAction)
                
                guard let layoutVC = RSActionCreators.generateLayout(for: route, state: state, store: store, layoutManager: layoutManager) else {
                    let routeRequestAction = ChangeRouteFailure(route: route)
                    store.dispatch(routeRequestAction)
                    return nil
                }
                
                delegate.presentLayout(viewController: layoutVC, completion: { (completed) in
                    
                    if completed {
                        let routeRequestAction = ChangeRouteSuccess(route: route)
                        store.dispatch(routeRequestAction)
                        
                        guard let lvc = layoutVC as? RSLayoutViewControllerProtocol else {
                            return
                        }
                        
                        lvc.layoutDidLoad()
                    }
                    else {
                        let routeRequestAction = ChangeRouteFailure(route: route)
                        store.dispatch(routeRequestAction)
                    }
                    
                })
                
            }
            
            return nil
        }
    }
    
    static func generateLayout(for route: RSRoute, state: RSState, store: Store<RSState>, layoutManager: RSLayoutManager ) -> UIViewController? {
        
        guard let layout = RSStateSelectors.layout(state, for: route.layout) else {
            return nil
        }
        return layoutManager.generateLayout(layout: layout, store: store)
    }

}
