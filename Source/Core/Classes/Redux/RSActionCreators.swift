//
//  RSActionCreators.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import Gloss
import ResearchKit
import ResearchSuiteResultsProcessor
import UserNotifications
import ResearchSuiteTaskBuilder

public typealias RSAnonymousAction = (_ state: RSState, _ store: Store<RSState>) -> Action?

public class RSActionCreators: NSObject {
    
    

    //loads json from (fileName, directory)
    //uses selector to select the array we want to process
    //converts each JSON element in array to an object
    //converts each object into an action
    //dispatches each action
    private static func addArrayOfObjectsFromFile<T>(fileName: String, inDirectory: String? = nil, configJSONBaseURL: String? = nil, selector: @escaping (JSON) -> [JSON]?, flatMapFunc: @escaping (JSON) -> T?, mapFunc: @escaping (T) -> Action) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            let json: JSON? = {
                
                guard let urlBase = configJSONBaseURL else {
                    return nil
                }
                
                let urlPath: String = inDirectory != nil ? inDirectory! + "/" + fileName : fileName
                if let url = URL(string: urlBase + urlPath) {
                    return RSHelpers.getJSON(forURL: url)
                }
                else {
                    return RSHelpers.getJSON(fileName: fileName, inDirectory: inDirectory, configJSONBaseURL: urlBase)
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
    
    public static func addMeasuresFromFile(fileName: String, inDirectory: String? = nil, measureManager: RSMeasureManager, configJSONBaseURL: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return { state, store in
            
            store.dispatch(addArrayOfObjectsFromFile(
                fileName: fileName,
                inDirectory: inDirectory,
                configJSONBaseURL: configJSONBaseURL,
                selector: { "measures" <~~ $0 },
                flatMapFunc: { measureManager.generate(jsonObject: $0, state: state) },
                mapFunc: { AddMeasureAction(measure: $0) }
            ))
            
            return nil
        }
        
    }
    
    public static func addActivitiesFromFile(fileName: String, activityManager: RSActivityManager, inDirectory: String? = nil, configJSONBaseURL: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return { state, store in
            
            store.dispatch(addArrayOfObjectsFromFile(
                fileName: fileName,
                inDirectory: inDirectory,
                configJSONBaseURL: configJSONBaseURL,
                selector: { "activities" <~~ $0 },
                flatMapFunc: { activityManager.generate(jsonObject: $0, state: state) },
                mapFunc: { AddActivityAction(activity: $0) }
            ))
            
            return nil
        }
        
    }
    
    public static func addLayoutsFromFile(fileName: String, layoutManager: RSLayoutManager, inDirectory: String? = nil, configJSONBaseURL: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return { state, store in
            
            store.dispatch(addArrayOfObjectsFromFile(
                fileName: fileName,
                inDirectory: inDirectory,
                configJSONBaseURL: configJSONBaseURL,
                selector: { "layouts" <~~ $0 },
                flatMapFunc: { layoutManager.generateLayout(jsonObject: $0, state: state) },
                mapFunc: { AddLayoutAction(layout: $0) }
            ))
            
            return nil
        }
        
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
    
    public static func reloadConfig() -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
//            RSApplicationDelegate.appDelegate.reloadConfig()
            
            return ReloadConfigurationRequest()
        }
    }
    
    public static func queueActivity(activityID: String, context: [String: AnyObject]?, extraOnCompletionActions: RSOnCompletionActions?) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return QueueActivityAction(uuid: UUID(), activityID: activityID, context: context, onCompletionActions: extraOnCompletionActions)
        }
    }
    
    public static func dequeueActivity(activityInstanceUUID: UUID) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return DequeueActivityAction(uuid: activityInstanceUUID)
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
    
    public static func sinkDatapoints(datapoints: [RSDatapoint], dataSinkIdentifiers: [String]) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            datapoints.forEach { datapoint in
                dataSinkIdentifiers.forEach({ (identifier) in
                    let action: Action = RSSinkDatapointAction(dataSinkIdentifier: identifier, datapoint: datapoint)
                    store.dispatch(action)
                })
            }
            
            return nil
        }
    }
    
    public static func presentActivity(on viewController: UIViewController, activityManager: RSActivityManager) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.presentActivity", level: .info, message: "Presenting Activity")
            
            //make sure we are not in the middle of routing
            //and there is a valid route
            guard !RSStateSelectors.isRouting(state),
//                RSStateSelectors.currentRoute(state) != nil else {
            RSStateSelectors.currentPath(state) != nil else {
                RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.presentActivity", level: .info, message: "In the middle of routing, so not presenting")
                return nil
            }
            
            //if nothing is presented and there are things to present, then begin presentation on delegate
            guard !RSStateSelectors.isPresenting(state),
                RSStateSelectors.presentedActivity(state) == nil else {
                    RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.presentActivity", level: .info, message: "We're already presenting or in the processos of presenting an activity \(RSStateSelectors.presentedActivity(state)?.1)")
                return nil
            }
            
            guard let firstActivity: (UUID, String, [String: AnyObject]?, RSOnCompletionActions?) = RSStateSelectors.getNextActivity(state) else {
                RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.presentActivity", level: .info, message: "No activities to present")
                return nil
            }
            
            guard let activity = RSStateSelectors.activity(state, for: firstActivity.1) else {
                    
                    store.dispatch(RSActionCreators.dequeueActivity(activityInstanceUUID: firstActivity.0))
        
                    RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.presentActivity", level: .error, message: "Could not generate activity for \(firstActivity.1). Removing from the queue")
                    return nil
            }

            let extraContext: [String: AnyObject] = firstActivity.2 ?? [:]

            let taskBuilderStateHelper = RSTaskBuilderStateHelper(store: store, extraStateValues: extraContext)

            let stepTreeBuilder = RSStepTreeBuilder(
                stateHelper: taskBuilderStateHelper,
                localizationHelper: RSApplicationDelegate.appDelegate.localizationHelper,
                nodeGeneratorServices: RSApplicationDelegate.appDelegate.stepTreeNodeGenerators,
                elementGeneratorServices: RSApplicationDelegate.appDelegate.elementGeneratorServices,
                stepGeneratorServices: RSApplicationDelegate.appDelegate.stepGeneratorServices,
                answerFormatGeneratorServices: RSApplicationDelegate.appDelegate.answerFormatGeneratorServices)
            
            
            guard let task = activityManager.taskForActivity(activity: activity, state: state, stepTreeBuilder: stepTreeBuilder) else {
                
                store.dispatch(RSActionCreators.dequeueActivity(activityInstanceUUID: firstActivity.0))
                
                RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.presentActivity", level: .error, message: "Could not generate Task for Activity \(firstActivity.1). Removing from the queue")
                return nil
            }
            
            let taskFinishedHandler: ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ()) = { (taskViewController, reason, error) in
                
                RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.presentActivity", level: .info, message: "Task finished handler: \(firstActivity.1) has completed with reason \(reason)")
                
                //process on success action
                if reason == ORKTaskViewControllerFinishReason.completed {
                    let taskResult = taskViewController.result
                    RSActionCreators.processOnSuccessActions(
                        activity: activity,
                        taskResult: taskResult,
                        store: store,
                        extraContext: extraContext,
                        extraOnCompletionActions: firstActivity.3
                    )
                }
                    //process on failure actions
                else {
                    RSActionCreators.processOnFailureActions(
                        activity: activity,
                        store: store,
                        extraContext: extraContext,
                        extraOnCompletionActions: firstActivity.3
                    )
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
                RSActionCreators.processFinallyActions(
                    activity: activity,
                    store: store,
                    extraContext: extraContext,
                    extraOnCompletionActions: firstActivity.3
                )
                
                //NOTE: We are wiping out the storage directory, so any results should have been copied out of here
                
                if let outputDirectory = taskViewController.outputDirectory,
                    FileManager.default.fileExists(atPath: outputDirectory.path){
                    
                    do {
                        try FileManager.default.removeItem(at: outputDirectory)
                    }
                    catch let error as NSError {
                        fatalError("The output directory for the task with UUID: \(taskViewController.taskRunUUID.uuidString) could not be removed. Error: \(error.localizedDescription)")
                    }
                    
                }
                
                
                RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.presentActivity", level: .info, message: "Task finished handler: Actions have been processed, dismissing activity")
                //dismiss view controller
                store.dispatch(RSActionCreators.dismissActivity(firstActivity.0, activity: activity, viewController: viewController, activityManager: activityManager))
                
            }
            
            let taskViewController = RSTaskViewController(activityUUID: firstActivity.0, task: task, taskFinishedHandler: taskFinishedHandler)
            taskViewController.defaultResultSource = (task as? RSStepTree)
            task.taskViewController = taskViewController
            
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
            
            RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.presentActivity", level: .info, message: "Task view controller for \(firstActivity.1) has been instantiated. Dispatching PresentActivityRequest action.")
            
            let presentRequestAction = PresentActivityRequest(uuid: firstActivity.0, activityID: firstActivity.1)
            store.dispatch(presentRequestAction)
//            taskViewController.modalPresentationStyle = .overCurrentContext
            
            RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.presentActivity", level: .info, message: "PresentActivityRequest action has been dispatched for \(firstActivity.1). Presenting Task VC now.")
            
            viewController.present(taskViewController, animated: true, completion: {
                
                RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.presentActivity", level: .info, message: "Task VC for \(firstActivity.1) has been presented. Dispatching PresentActivitySuccess action.")
                
                let presentSuccessAction = PresentActivitySuccess(uuid: firstActivity.0, activityID: firstActivity.1, presentationTime: Date())
                store.dispatch(presentSuccessAction)
                
                RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.presentActivity", level: .info, message: "PresentActivitySuccess action has been dispatched for \(firstActivity.1).")
                
                if let onLaunchActions = activity.onLaunchActions {
                    store.processActions(actions: onLaunchActions, context: [:], store: store)
                }

            })
            
            return nil
        }
    }
    
    public static func dismissActivity(_ uuid: UUID, activity: RSActivity, viewController: UIViewController, activityManager: RSActivityManager) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.dismissActivity", level: .info, message: "Dismissing activty \(activity.identifier)")
            
            guard !RSStateSelectors.isDismissing(state) else {
                RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.dismissActivity", level: .info, message: "We're already dismissing an activity, returning")
                return nil
            }
            
            guard let presentedActivityPair = RSStateSelectors.presentedActivity(state) else {
                RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.dismissActivity", level: .info, message: "According to the state, there is no presented activity. Returning...")
                return nil
            }
            
            guard presentedActivityPair.0 == uuid else {
                    RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.dismissActivity", level: .info, message: "Cannot dismiss as the presented activity's UUID \(presentedActivityPair.0) does not match the UUID of the actiity we are dismissing \(uuid)")
                    return nil
            }
            
            RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.dismissActivity", level: .info, message: "Activity \(presentedActivityPair.1) is able to be dismissed. Disptching DismissActivityRequest action")
            let dismissRequestAction = DismissActivityRequest(uuid: presentedActivityPair.0, activityID: presentedActivityPair.1)
            store.dispatch(dismissRequestAction)
            
            RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.dismissActivity", level: .info, message: "DismissActivityRequest action has been dispatched for \(presentedActivityPair.1). Dismissing Task VC.")
            
            viewController.dismiss(animated: true, completion: {
                RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.dismissActivity", level: .info, message: "Task VC for \(presentedActivityPair.1) has been dismissed. Dispatching DismissActivitySuccess action.")
                let dismissSuccessAction = DismissActivitySuccess(uuid: presentedActivityPair.0, activityID: presentedActivityPair.1)
                store.dispatch(dismissSuccessAction)
                RSApplicationDelegate.appDelegate.logger?.log(tag: "RSActionCreators.dismissActivity", level: .info, message: "DismissActivitySuccess action has been dispatched for \(presentedActivityPair.1) ")
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
    
    private static func processOnSuccessActions(
        activity: RSActivity,
        taskResult: ORKTaskResult,
        store: Store<RSState>,
        extraContext: [String: AnyObject],
        extraOnCompletionActions: RSOnCompletionActions?
    ) {
        let onSuccessActionJSON: [JSON] = activity.onCompletion.onSuccessActions
        let context: [String: AnyObject] = extraContext.merging(["taskResult": taskResult], uniquingKeysWith: { (obj1, obj2) -> AnyObject in
            return obj2
        })
        
        store.processActions(actions: onSuccessActionJSON, context: context, store: store)
        
        if let extraOnSuccessActions = extraOnCompletionActions?.onSuccessActions {
            extraOnSuccessActions.forEach { generator in
                let action = generator(context)
                store.dispatch(action)
            }
        }
    }
    
    private static func processOnFailureActions(
        activity: RSActivity,
        store: Store<RSState>,
        extraContext: [String: AnyObject],
        extraOnCompletionActions: RSOnCompletionActions?
    ) {
        let onFailureActionJSON: [JSON] = activity.onCompletion.onFailureActions
        let context: [String: AnyObject] = extraContext
        store.processActions(actions: onFailureActionJSON, context: context, store: store)
        
        if let extraOnFailureActions = extraOnCompletionActions?.onFailureActions {
            extraOnFailureActions.forEach { generator in
                let action = generator(context)
                store.dispatch(action)
            }
        }
    }
    
    private static func processFinallyActions(
        activity: RSActivity,
        store: Store<RSState>,
        extraContext: [String: AnyObject],
        extraOnCompletionActions: RSOnCompletionActions?
    ) {
        let finallyActionJSON: [JSON] = activity.onCompletion.finallyActions
        let context: [String: AnyObject] = extraContext
        store.processActions(actions: finallyActionJSON, context: context, store: store)
        
        if let extraFinallyActions = extraOnCompletionActions?.finallyActions {
            extraFinallyActions.forEach { generator in
                let action = generator(context)
                store.dispatch(action)
            }
        }
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
            guard let dataSink = backEnd as? RSDataSink else {
                assertionFailure("Back end not convertible to data sink.")
                return nil
            }
            return RegisterDataSinkAction(identifier: identifier, dataSink: dataSink)
        }
    }
    
    public static func unregisterResultsProcessorBackEnd(identifier: String) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return UnregisterDataSinkAction(identifier: identifier)
        }
    }
    
    public static func registerDataSink(identifier: String, dataSink: RSDataSink) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return RegisterDataSinkAction(identifier: identifier, dataSink: dataSink)
        }
    }
    
    public static func unregisterDataSink(identifier: String) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return UnregisterDataSinkAction(identifier: identifier)
        }
    }
    
    public static func registerDataSource(identifier: String, dataSource: RSDataSource) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return RegisterDataSourceAction(identifier: identifier, dataSource: dataSource)
        }
    }
    
    public static func unregisterDataSource(identifier: String) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            return UnregisterDataSourceAction(identifier: identifier)
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

    public static func addNotificationsFromFile(fileName: String, inDirectory: String? = nil, configJSONBaseURL: String? = nil) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return addArrayOfObjectsFromFile(
            fileName: fileName,
            inDirectory: inDirectory,
            configJSONBaseURL: configJSONBaseURL,
            selector: { "notifications" <~~ $0 },
            flatMapFunc: { RSNotification(json: $0) },
            mapFunc: { AddNotificationAction(notification: $0) }
        )

    }
    
    public static func addNotification(notification: RSNotification) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return { state, store in
            return AddNotificationAction(notification: notification)
        }
        
    }
    
    public static func updateNotification(notification: RSNotification) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return { state, store in
            return UpdateNotificationAction(notification: notification)
        }
        
    }
    
    public static func removeNotification(notification: RSNotification) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        
        return { state, store in
            return RemoveNotificationAction(notificationIdentifier: notification.identifier)
        }
        
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
    
    public static func definedAction(identifier: String, context: [String: AnyObject] = [:]) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            guard let definedAction = RSStateSelectors.getDefinedAction(state, for: identifier) else {
                return nil
            }
            
            let actionManager: RSActionManager = RSApplicationDelegate.appDelegate.actionManager
            actionManager.processAction(action: definedAction.json, context: context, store: store)
            return nil
        }
    }
    
    public static func updateScheduler(schedulerEventUpdate: RSSchedulerEventUpdate) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
//            return SetScheduleEvents(scheduleEvents: scheduleEvents)
            return UpdateScheduler(schedulerEventUpdate: schedulerEventUpdate)
        }
    }
    
    public static func markScheduleEventCompleted(eventId: String, taskRuns: [UUID]) -> (_ state: RSState, _ store: Store<RSState>) -> Action? {
        return { state, store in
            
            guard let scheduler = RSApplicationDelegate.appDelegate?.scheduler else {
                return nil
            }
            
            scheduler.markEventCompleted(eventId: eventId, taskRuns: taskRuns, state: state)
            
            return nil
        }
    }

    
    
}
