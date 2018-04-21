//
//  RSActionCreators.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import ReSwift
import Gloss
import ResearchKit
import ResearchSuiteResultsProcessor
import UserNotifications

public class RSActionCreators: NSObject {
    

    //loads json from (fileName, directory)
    //uses selector to select the array we want to process
    //converts each JSON element in array to an object
    //converts each object into an action
    //dispatches each action
    private static func addArrayOfObjectsFromFile<T>(fileName: String, inDirectory: String? = nil, configJSONBaseURL: String? = nil, selector: @escaping (JSON) -> [JSON]?, flatMapFunc: @escaping (JSON) -> T?, mapFunc: @escaping (T) -> Action) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            let json: JSON? = {
                
                let urlPath: String = inDirectory != nil ? inDirectory! + "/" + fileName : fileName
                if  let urlBase = configJSONBaseURL,
                    let url = URL(string: urlBase + urlPath) {
                    
                    return RSHelpers.getJSON(forURL: url)
                    
                }
                else {
                    return RSHelpers.getJson(forFilename: fileName, inDirectory: inDirectory) as? JSON
                }
                
            }()
            
            guard let jsonElement = json,
                let jsonArray = selector(jsonElement) else {
                    return nil
            }
            
            jsonArray
                .compactMap(flatMapFunc)
                .map(mapFunc)
                .forEach { store.dispatch($0) }
            
            return nil
        }
    }
    
    public static func addStateValuesFromFile(fileName: String, inDirectory: String? = nil, configJSONBaseURL: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {

        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            configJSONBaseURL: configJSONBaseURL,
            selector: { "state" <~~ $0 },
            flatMapFunc: { RSStateValue(json: $0) },
            mapFunc: { AddStateValueAction(stateValue: $0) }
        )
        
    }
    
    public static func addConstantsFromFile(fileName: String, inDirectory: String? = nil, configJSONBaseURL: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            configJSONBaseURL: configJSONBaseURL,
            selector: { "constants" <~~ $0 },
            flatMapFunc: { RSConstantValue(json: $0) },
            mapFunc: { AddConstantValueAction(constantValue: $0) }
        )
        
    }
    
    public static func addFunctionsFromFile(fileName: String, inDirectory: String? = nil, configJSONBaseURL: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {

        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            configJSONBaseURL: configJSONBaseURL,
            selector: { "functions" <~~ $0 },
            flatMapFunc: { RSDefinedFunctionValue(json: $0) },
            mapFunc: { AddFunctionValueAction(functionValue: $0) }
        )
        
    }
    
    public static func addPredicateFunctionsFromFile(fileName: String, inDirectory: String? = nil, configJSONBaseURL: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            configJSONBaseURL: configJSONBaseURL,
            selector: { "predicateFunctions" <~~ $0 },
            flatMapFunc: { RSPredicateFunctionValue(json: $0) },
            mapFunc: { AddFunctionValueAction(functionValue: $0) }
        )
        
    }
    
    public static func addDefinedActionsFromFile(fileName: String, inDirectory: String? = nil, configJSONBaseURL: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            configJSONBaseURL: configJSONBaseURL,
            selector: { "definedActions" <~~ $0 },
            flatMapFunc: { RSDefinedAction(json: $0) },
            mapFunc: { AddDefinedAction(definedAction: $0) }
        )
        
    }
    
    public static func addMeasuresFromFile(fileName: String, inDirectory: String? = nil, configJSONBaseURL: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            configJSONBaseURL: configJSONBaseURL,
            selector: { "measures" <~~ $0 },
            flatMapFunc: { RSMeasure(json: $0) },
            mapFunc: { AddMeasureAction(measure: $0) }
        )
        
    }
    
    public static func addActivitiesFromFile(fileName: String, inDirectory: String? = nil, configJSONBaseURL: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            configJSONBaseURL: configJSONBaseURL,
            selector: { "activities" <~~ $0 },
            flatMapFunc: { RSActivity(json: $0) },
            mapFunc: { AddActivityAction(activity: $0) }
        )
        
    }
    
    public static func addLayoutsFromFile(fileName: String, layoutManager: RSLayoutManager, inDirectory: String? = nil, configJSONBaseURL: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            configJSONBaseURL: configJSONBaseURL,
            selector: { "layouts" <~~ $0 },
            flatMapFunc: { layoutManager.generateLayout(jsonObject: $0) },
            mapFunc: { AddLayoutAction(layout: $0) }
        )
        
    }
//
//    public static func addRoutesFromFile(fileName: String, inDirectory: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
//        
//        return addArrayOfObjectsFromFile(
//            fileName: fileName,
//            inDirectory: inDirectory,
//            selector: { "routes" <~~ $0 },
//            flatMapFunc: { RSRoute(json: $0) },
//            mapFunc: { AddRouteAction(route: $0) }
//        )
//        
//    }
    
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
                return SetValueInState(key: key, value: nil)
            }
            
            //check to see if value can be converted to specified type
            //value is of type NSObject at this point
            if RSStateValue.typeMatches(type: stateValueMetadata.type, object: value) {
                return SetValueInState(key: key, value: value)
            }
            
            return nil
        }
    }
    
    //for now, the most direct way to do this is filter data items by state manager id, reset data item
    public static func resetStateManager(stateManagerID: String) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            let stateValueMetadata = RSStateSelectors.getStateValueMetadataForStateManager(state, stateManagerID: stateManagerID)
            
            stateValueMetadata.forEach { stateValue in
                store.dispatch(ResetValueInState(key: stateValue.identifier))
            }
            
            return nil
        }
    }

    
    public static func registerFunction(identifier: String, function: @escaping (RSState) -> AnyObject?) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return RegisterFunctionAction(identifier: identifier, function: function)
        }
    }
    
    public static func unregisterFunction(identifier: String) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return UnregisterFunctionAction(identifier: identifier)
        }
    }
    
    public static func requestPathChange(path: String, forceReroute: Bool = false) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
//            assert(RSStateSelectors.isRouting(state) == false)
            return ChangePathRequest(uuid: UUID(), requestedPath: path, forceReroute: forceReroute)
        }
    }
    
    public static func presentActivity(on viewController: UIViewController, activityManager: RSActivityManager) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            //make sure we are not in the middle of routing
            //and there is a valid route
            guard !RSStateSelectors.isRouting(state),
//                RSStateSelectors.currentRoute(state) != nil else {
            RSStateSelectors.currentPath(state) != nil else {
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
                
                
                if let newState = store.state,
                    let presentedActivityPair = RSStateSelectors.presentedActivity(newState) {

                    let action = LogActivityAction(
                        activityID: presentedActivityPair.1,
                        uuid: taskViewController.taskRunUUID,
                        startTime: presentedActivityPair.2,
                        endTime: Date(),
                        completed: reason == ORKTaskViewControllerFinishReason.completed
                    )
                    
                    store.dispatch(action)
                    
                }
                
                //process finally actions
                RSActionCreators.processFinallyActions(activity: activity, store: store)
                
                //NOTE: We are wiping out the storage directory, so any results should have been copied out of here
                
                if let outputDirectory = taskViewController.outputDirectory,
                    FileManager.default.fileExists(atPath: outputDirectory.absoluteString){
                    
                    do {
                        try FileManager.default.removeItem(at: outputDirectory)
                    }
                    catch let error as NSError {
                        fatalError("The output directory for the task with UUID: \(taskViewController.taskRunUUID.uuidString) could not be removed. Error: \(error.localizedDescription)")
                    }
                    
                }
                
                
                
                //dismiss view controller
                store.dispatch(RSActionCreators.dismissActivity(firstActivity.0, activity: activity, viewController: viewController, activityManager: activityManager))
                
            }
            
            let taskViewController = RSTaskViewController(activityUUID: firstActivity.0, task: task, taskFinishedHandler: taskFinishedHandler)
            
            do {
                let defaultFileManager = FileManager.default
                
                // Identify the documents directory.
                let documentsDirectory = try defaultFileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                
                // Create a directory based on the `taskRunUUID` to store output from the task.
                let outputDirectory = documentsDirectory.appendingPathComponent(taskViewController.taskRunUUID.uuidString)
                try defaultFileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
                
//                debugPrint("Storing results in \(outputDirectory.absoluteString)")
                
                taskViewController.outputDirectory = outputDirectory
            }
            catch let error as NSError {
                fatalError("The output directory for the task with UUID: \(taskViewController.taskRunUUID.uuidString) could not be created. Error: \(error.localizedDescription)")
            }
            
            let presentRequestAction = PresentActivityRequest(uuid: firstActivity.0, activityID: firstActivity.1)
            store.dispatch(presentRequestAction)
            taskViewController.modalPresentationStyle = .overCurrentContext
            
            viewController.present(taskViewController, animated: true, completion: {
                
                let presentSuccessAction = PresentActivitySuccess(uuid: firstActivity.0, activityID: firstActivity.1, presentationTime: Date())
                store.dispatch(presentSuccessAction)
                
                if let onLaunchActions = activity.onLaunchActions {
                    store.processActions(actions: onLaunchActions, context: [:], store: store)
                }

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
    
    //NOTE: THIS IS FOR DEVELOPMENT ONLY!!!!!!
    public static func forceDismissActivity(flushActivityQueue: Bool) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            if flushActivityQueue {
                store.dispatch(FlushActivityQueue())
            }
            
            guard !RSStateSelectors.isDismissing(state),
                let presentedActivityPair = RSStateSelectors.presentedActivity(state) else {
                    return nil
            }
            
            let topViewController = RSApplicationDelegate.appDelegate.rootViewController.topViewController
            let dismissRequestAction = DismissActivityRequest(uuid: presentedActivityPair.0, activityID: presentedActivityPair.1)
            store.dispatch(dismissRequestAction)
            
            topViewController.dismiss(animated: true, completion: {
                let dismissSuccessAction = DismissActivitySuccess(uuid: presentedActivityPair.0, activityID: presentedActivityPair.1)
                store.dispatch(dismissSuccessAction)
            })
            
            return nil
        }
    }
    
    private static func processOnSuccessActions(activity: RSActivity, taskResult: ORKTaskResult, store: Store<RSState>) {
        let onSuccessActionJSON: [JSON] = activity.onCompletion.onSuccessActions
        let context: [String: AnyObject] = ["taskResult": taskResult]
        store.processActions(actions: onSuccessActionJSON, context: context, store: store)
    }
    
    private static func processOnFailureActions(activity: RSActivity, store: Store<RSState>) {
        let onFailureActionJSON: [JSON] = activity.onCompletion.onFailureActions
        let context: [String: AnyObject] = [:]
        store.processActions(actions: onFailureActionJSON, context: context, store: store)
    }
    
    private static func processFinallyActions(activity: RSActivity, store: Store<RSState>) {
        let finallyActionJSON: [JSON] = activity.onCompletion.finallyActions
        let context: [String: AnyObject] = [:]
        store.processActions(actions: finallyActionJSON, context: context, store: store)
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
    
//    public static func setRoute(route: RSRoute, layoutManager: RSLayoutManager, delegate: RSRouterDelegate) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
//        return { state, store in
//            
//            guard !RSStateSelectors.isRouting(state) else {
//                    return nil
//            }
//            
//            //also verify that we are not in the middle of presenting a task
//            guard !RSStateSelectors.isPresenting(state),
//                RSStateSelectors.presentedActivity(state) == nil,
//                !RSStateSelectors.isDismissing(state) else {
//                    return nil
//            }
//            
//            //if current route is nil, route first route
//            //if current route is not first route, route first route
//            let currentRoute = RSStateSelectors.currentRoute(state)
//            
//            if currentRoute == nil ||
//                currentRoute!.identifier != route.identifier {
//                
//                //I HAVE NO IDEA HOW THIS WILL WORK FOR TAB BARS!!
//                
//                //we can either set the root layout, push a layout onto the stack, or pop the layout off
//                //if we are setting the root, the selected route will not have a parent and it will not be the parent of the current route
//                
//                //if we are to push a layout onto the stack, current route will be the parent of the selected route
//                
//                //if we are to pop a layout off the stack, the selected route will the the parent of the current route
//                
//                //here, check to see that if the route has a parent
//                //its parent is the current route
//                //NOTE: In the future, we can update this to remove the constraint
//                //however, this should be fine for now
//                
//                
//                let routeRequestAction = ChangeRouteRequest(route: route)
//                store.dispatch(routeRequestAction)
//                
//                delegate.showRoute(route: route, state: state, store: store, completion: { (completed, layoutVC) in
//                    
//                    if completed {
//                        let routeRequestAction = ChangeRouteSuccess(route: route)
//                        store.dispatch(routeRequestAction)
//                        assert(layoutVC != nil)
//                        layoutVC?.layoutDidLoad()
//                    }
//                    else {
//                        assert(layoutVC != nil, "Routing Failure: Could not generate a layout. This should NEVER occur\n\nCheck that the layout ID in the route is correct!!!")
//                        let routeRequestAction = ChangeRouteFailure(route: route)
//                        store.dispatch(routeRequestAction)
//                    }
//                    
//                })
//            }
//            
//            return nil
//        }
//    }
//    
//    static func generateLayout(for route: RSRoute, state: RSState, store: Store<RSState>, layoutManager: RSLayoutManager ) -> UIViewController? {
//        
//        //note that if we cant generate a layout, we go into an endless loop!!
//        //TODO: Fix THIS!!!
//        guard let layout = RSStateSelectors.layout(state, for: route.layout) else {
//            return nil
//        }
//        return layoutManager.generateLayout(layout: layout, store: store)
//    }
    
    public static func registerResultsProcessorBackEnd(identifier: String, backEnd: RSRPBackEnd) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return RegisterResultsProcessorBackEndAction(identifier: identifier, backEnd: backEnd)
        }
    }
    
    public static func unregisterResultsProcessorBackEnd(identifier: String) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return UnregisterResultsProcessorBackEndAction(identifier: identifier)
        }
    }
    
    static public func completeConfiguration() -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return CompleteConfiguration()
        }
    }
    
    static public func logNotificationInteraction(notificationID: String, date: Date) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return LogNotificationAction(notificationID: notificationID, date: date)
        }
    }
    
    static public func signOut() -> Action? {
        return SignOutRequest()
    }

    
    //Notifications
    public static func fetchPendingNotifications() -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return { state, store in
            
            //ignore if is fetching
            guard !RSStateSelectors.isFetchingNotifications(state) else {
                return nil
            }
            
            let fetchRequestAction = FetchPendingNotificationsRequest()
            store.dispatch(fetchRequestAction)
            
            UNUserNotificationCenter.current().getPendingNotificationRequests { (pendingRequests) in
                
                let fetchSuccessAction = FetchPendingNotificationsSuccess(pendingNotifications: pendingRequests, fetchTime: Date())
                DispatchQueue.main.async {
                    store.dispatch(fetchSuccessAction)
                }
            }

            return nil
        }
    }

    public static func addNotificationsFromFile(fileName: String, inDirectory: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            selector: { "notifications" <~~ $0 },
            flatMapFunc: { RSNotification(json: $0) },
            mapFunc: { AddNotificationAction(notification: $0) }
        )
        
    }
    
    public static func requestLocationAuthorization(always: Bool) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return { state, store in
            
            guard RSStateSelectors.isRequestingLocationAuthorization(state) == false else {
                return nil
            }
            
            let request = UpdateLocationAuthorizationStatusRequest(always: always)
            store.dispatch(request)
            
            //the success
            if let locationManager = RSApplicationDelegate.appDelegate.locationManager {
                locationManager.requestLocationAuthorization(always: always)
                return nil
            }
            else {
                assertionFailure("Location Manager Not Enabled")
                return UpdateLocationAuthorizationStatusFailure()
            }
        }
    }
    
    public static func completeLocationAuthorizationRequest(status: CLAuthorizationStatus) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return UpdateLocationAuthorizationStatusSuccess(status: status)
        }
    }
    
    public static func setLocationAuthorizationStatus(status: CLAuthorizationStatus) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return SetLocationAuthorizationStatus(status: status)
        }
    }
    
    public static func setPreventSleep(preventSleep: Bool) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return SetPreventSleep(preventSleep: preventSleep)
        }
    }
    
    public static func fetchCurrentLocation(onCompletion: RSPromise) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            guard !RSStateSelectors.isFetchingLocation(state) else {
                return nil
            }
            
            let request = FetchCurrentLocationRequest()
            store.dispatch(request)
            
            if let locationManager = RSApplicationDelegate.appDelegate.locationManager {
                locationManager.fetchCurrentLocation(completion: { (locations, error) in
                    
                    
                    if let locationsToProcess = locations {
                        
                        let action = FetchCurrentLocationSuccess(locations: locationsToProcess)
                        store.dispatch(action)
                        
                        //process onSuccess Actions
                        if let onSuccessActions = onCompletion.onSuccessActions {
                            locationsToProcess.forEach { location in
                                let locationEvent = RSLocationEvent(location: location, source: "Location Request", uuid: UUID())
                                store.processActions(actions: onSuccessActions, context: ["sensedLocation": location, "sensedLocationEvent": locationEvent], store: store)
                            }
                        }
                    
                    }
                    else if let error = error {
                        
                        let action = FetchCurrentLocationFailure(error: error)
                        store.dispatch(action)
                        
                        //process onFailure Actions
                        if let onFailureAction = onCompletion.onFailureActions {
                            store.processActions(actions: onFailureAction, context: ["error": error as NSError], store: store)
                        }
                        
                    }
                    else {
                        assertionFailure("Locations and Error cannot both be nil")
                    }
                    
                })
                return nil
            }
            else {
                assertionFailure("Location Manager Not Enabled")
                return FetchCurrentLocationFailure(error: RSLocationManager.LocationManagerError.locationManagerDisabled)
            }
        }
    }
    
    public static func setLocationMonitoringEnabled(enabled: Bool) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return SetLocationMonitoringEnabled(enabled: enabled)
        }
    }
    
    public static func setVisitMonitoringEnabled(enabled: Bool) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return SetVisitMonitoringEnabled(enabled: enabled)
        }
    }
    
    
}
