//
//  RSApplicationDelegate.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import ResearchSuiteTaskBuilder
import ResearchSuiteResultsProcessor
import CoreLocation
import Gloss
import ResearchSuiteExtensions
import ResearchKit

public enum RSConfiguration: String {
    
    case development = "development"
    case testing = "testing"
    case staging = "staging"
    case production = "production"
    
}

open class RSApplicationDelegate: UIResponder, UIApplicationDelegate, StoreSubscriber {
    
    static let TAG = "RSApplicationDelegate"
    
    public var window: UIWindow?
    public private(set) var routingViewController: RSRoutingViewController?
    public var rootViewController: RSRootViewController! {
        return self.routingViewController!
    }
    
    public var chConfig: RSConfiguration!
    
    public var feedbackViewController: RSFeedbackViewController?
    
    public var activityManager: RSActivityManager!
    public var actionManager: RSActionManager!
    public var notificationManager: RSNotificationManager?
    public var locationManager: RSLocationManager?
    public var routeManager: RSRouteManager!
    public var collectionViewCellManager: RSCollectionViewCellManager!
    public var stateObjectManager: RSStateObjectManager!
    
    public var storeManager: RSStoreManager!
    public var taskBuilderStateHelper: RSTaskBuilderStateHelper!
    public var taskBuilder: RSTBTaskBuilder!
    public var stepTreeBuilder: RSStepTreeBuilder!
    
    public var resultsProcessorFrontEnd: RSRPFrontEndService!
    public var persistentStoreSubscriber: RSStatePersistentStoreSubscriber!
    
    public var layoutManager: RSLayoutManager!
    
    public var openURLManager: RSOpenURLManager!
    
    public static var appDelegate: RSApplicationDelegate! {
        return UIApplication.shared.delegate as! RSApplicationDelegate
    }
    
    public var store: Store<RSState>! {
        return storeManager.store
    }
    
    weak var weakStore: Store<RSState>?
    
    private var lastState: RSState?
    
    open var logger: RSLogger?
    
    open var cellControllerGenerators: [RSEnhancedMultipleChoiceCellControllerGenerator.Type] = [
        RSEnhancedMultipleChoiceCellWithTextScaleAccessoryController.self,
        RSEnhancedMultipleChoiceCellWithNumericScaleAccessoryController.self,
        RSEnhancedMultipleChoiceCellWithTextFieldAccessoryController.self,
        //THis is a catchall and MUST go last
        RSEnhancedMultipleChoiceBaseCellController.self
    ]
    
    open var stepGeneratorServices: [RSTBStepGenerator] {
        return [
            RSTBInstructionStepGenerator(),
            RSTBTextFieldStepGenerator(),
            RSTBIntegerStepGenerator(),
            RSTBTimePickerStepGenerator(),
            RSTBFormStepGenerator(),
            RSTBDatePickerStepGenerator(),
            RSTBSingleChoiceStepGenerator(),
            RSTBMultipleChoiceStepGenerator(),
            RSTBBooleanStepGenerator(),
            RSTBPasscodeStepGenerator(),
            RSTBScaleStepGenerator(),
            RSTBLocationStepGenerator(),
            RSTBImageCaptureStepGenerator(),
            RSEnhancedSingleChoiceStepGenerator(cellControllerGenerators: self.cellControllerGenerators),
            RSEnhancedMultipleChoiceStepGenerator(cellControllerGenerators: self.cellControllerGenerators),
        ]
    }
    
    open var answerFormatGeneratorServices:  [RSTBAnswerFormatGenerator] {
        return [
            RSTBTextFieldStepGenerator(),
            RSTBIntegerStepGenerator(),
            RSTBTimePickerStepGenerator(),
            RSTBDatePickerStepGenerator(),
            RSTBScaleStepGenerator(),
            RSTBTextScaleStepGenerator(),
            RSEnhancedTextScaleStepGenerator(),
            RSEnhancedScaleStepGenerator()
        ]
    }
    
    open var elementGeneratorServices: [RSTBElementGenerator] {
        return [
            RSTBElementListGenerator(),
            RSTBElementFileGenerator(),
            RSTBElementSelectorGenerator()
        ]
    }
    
    open var frontEndResultTransformers: [RSRPFrontEndTransformer.Type] {
        return [
            RSLocationStepResult.self,
            RSTimeOfDayStepResult.self,
            RSBooleanStepResult.self,
            RSTextStepResult.self,
            RSSingleChoiceStepResult.self,
            RSEnhancedMultipleChoiceValuesResultTransform.self,
            RSJSONCollectionResultTransformer.self,
            RSEnhancedMultipleChoiceResultTransform.self,
            RSScaleStepResult.self
        ]
    }
    
    open var stepTreeNodeGenerators: [RSStepTreeNodeGenerator.Type] {
        return [
            RSStepTreeTemplatedNodeGenerator.self,
            RSStepTreeElementListGenerator.self,
            RSStepTreeElementFileGenerator.self
        ]
    }
    
//    open var layoutGenerators: [RSLayoutGenerator] {
//        return [
//            RSListLayoutGenerator(),
//            RSTitleLayoutGenerator(),
//            RSTabLayoutGenerator()
//        ]
//    }
    
    open var layoutGenerators: [RSLayoutGenerator.Type] {
        return [
            RSRootLayout.self,
            RSTitleLayout.self,
            RSListLayout.self,
            RSLayoutFile.self,
            RSTabBarLayout.self,
            RSMoreLayout.self,
            RSCollectionLayout.self,
            RSCalendarLayout.self,
            RSWebLayout.self
        ]
    }
    
    open var pathGenerators: [RSPathGenerator.Type] {
        return [
            RSExactPath.self,
            RSPrefixPath.self,
            RSParamPath.self
        ]
    }
    
    open var routeGenerators: [RSRouteGenerator.Type] {
        return [
            RSRoute.self,
            RSRedirectRoute.self,
            RSProtectedRoute.self
        ]
    }
    
    open var notificationProcessors: [RSNotificationProcessor] {
        return [
            RSStandardNotificationProcessor(),
            RSDailyNotificationProcessor()
        ]
    }
    
    open var notificationSupport: Bool {
        return true
    }
    
    open var locationSupport: Bool {
        return true
    }
    
    open var locationManagerConfig: RSLocationManagerConfiguration? {
        return nil
    }
    
//    open var persistentStoreObjectDecodingClasses: [Swift.AnyClass] {
//        return [
//            NSDictionary.self,
//            NSArray.self,
//            NSDate.self,
//            CLLocation.self,
//            NSDateComponents.self,
//            NSUUID.self
//        ]
//    }
    
    open var openURLDelegates: [RSOpenURLDelegate] {
        return [self.actionManager]
    }
    
    open var actionCreatorTransforms: [RSActionTransformer.Type] {
        return [
            RSSinkDatapointActionTransformer.self,
            RSSendResultToServerActionTransformer.self,
            RSSetValueInStateActionTransformer.self,
            RSQueueActivityActionTransformer.self,
            RSResetStateManagerActionTransformer.self,
            RSShowAlertActionTranformer.self,
            RSSignOutActionTransformer.self,
            RSGroupActionTransformer.self,
            RSPrintValueActionTransformer.self,
            RSFetchCurrentLocationActionTransformer.self,
            RSPrintNotificationActionTransformer.self,
            RSEvaluatePredicateActionTransformer.self,
            RSSetPreventSleepAction.self,
            RSActionSwitchTransformer.self,
            RSRequestPathChangeActionTransformer.self,
            RSDefinedAction.self
        ]
    }
    
    open var valueTransforms: [RSValueTransformer.Type] {
        return [
            RSResultTransformValueTransformer.self,
            RSConstantValueTransformer.self,
            RSFunctionValueTransformer.self,
            RSStepTreeResultTransformValueTransformer.self,
            RSStateValueTransformer.self,
            RSSpecialValueTransformer.self,
            RSLiteralValueTransformer.self,
            RSDateComponentsTransform.self,
            RSSensedLocationValueTransform.self,
            RSSensedLocationEventTransform.self,
            RSSensedRegionTransitionEventTransform.self,
            RSSensedVisitEventTransform.self,
            RSDateTransform.self,
            RSNotificationTriggerDateTransformer.self,
            RSGeofenceRegionValueTransformer.self,
            RSArrayValueTransformer.self,
            RSPathTransformer.self,
            RSTemplatedStringValueTransformer.self,
            RSContextValueTransformer.self,
            RSDateFormatterValueTransform.self,
            RSPrettyPrintJSONTransformer.self
        ]
    }
    
    open var collectionViewCellGenerators: [RSCollectionViewCellGenerator.Type] {
        return [
            RSBasicCollectionViewCell.self,
//            RSCardCollectionViewCell.self
            RSTextCardCollectionViewCell.self
        ]
    }
    
    open var storeMiddleware: [RSMiddlewareProvider.Type] {
        #if DEBUG
            return [
                RSLoggingMiddleware.self,
                RSSendResultToServerMiddleware.self,
                RSAnalyticsMiddleware.self
            ]
        #else
            return [
                RSSendResultToServerMiddleware.self,
                RSAnalyticsMiddleware.self
            ]
        #endif
        
    }
    
    open var stateManagerGenerators: [RSStateManagerGenerator.Type] {
        return [
            RSFileStateManager.self,
            RSEphemeralStateManager.self
        ]
    }
    
    open var stateObjectTypes: [RSStateObject.Type] {
        return []
    }
    
    open var stateManagersFileName: String = "state"
    
    open var stateManagerDescriptors: [RSStateManagerDescriptor] {
        let selector: (JSON)-> [JSON]? = { "stateManagers" <~~ $0 }
        guard let json = RSHelpers.getJson(forFilename: self.stateManagersFileName) as? JSON,
            let jsonArray = selector(json) else {
                return []
        }
        
        return jsonArray.compactMap { RSStateManagerDescriptor(json: $0) }
    }
    
    open func newState(state: RSState) {

        if state.signOutRequested
            && !RSStateSelectors.isFetchingNotifications(state)
            && !RSStateSelectors.isPresentingPasscode(state)
            && !RSStateSelectors.isDismissingPasscode(state)
            && !RSStateSelectors.isPresenting(state)
            && !RSStateSelectors.isDismissing(state)
            && RSStateSelectors.isConfigurationCompleted(state) {
            
            let passcodeViewController = RSStateSelectors.passcodeViewController(state)

            self.signOut(completed: { (completed, error) in
                passcodeViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            })
        }
        
        //check for notifications being enabled
        guard let lastState = self.lastState else {
            self.lastState = state
            return
        }
        
        self.lastState = state
        
        if RSStateSelectors.shouldPreventSleep(state) != RSStateSelectors.shouldPreventSleep(lastState) {
            UIApplication.shared.isIdleTimerDisabled = RSStateSelectors.shouldPreventSleep(state)
        }
        
    }
    
    open func signOut(completed: (Bool, Error?) -> Swift.Void ) {
        self.startApplicationReset()
        completed(true, nil)
    }
    
    open func applicationReset(completion: @escaping (Bool, Error?) -> Void) {
        completion(true, nil)
    }
    
    private func finishApplicationReset() {
        
        //clear persistent store subscriber
        self.persistentStoreSubscriber.clearState { (completd, error) in
            
            self.persistentStoreSubscriber = nil
            
            self.taskBuilderStateHelper = nil
            self.taskBuilder = nil
            self.activityManager = nil
            self.actionManager = nil
            self.stateObjectManager = nil
            
            if self.notificationSupport {
                self.notificationManager?.cancelNotifications()
                self.notificationManager = nil
            }
            
            if self.locationSupport {
                self.locationManager?.stopMonitoringRegions()
                self.locationManager = nil
            }
            
            self.layoutManager = nil
            
            self.window?.rootViewController = UIViewController()
            self.window?.makeKeyAndVisible()

            self.routingViewController = nil
            
            self.openURLManager = nil
            
            
            //potentially clear the documents directory as well
            RSKeychainHelper.clearKeychain()
            
//            self.perform(#selector(self.printRefCount), with: nil, afterDelay: 5.0)
            
            self.initializeApplication(fromReset: true)
            
            self.store?.dispatch(RSActionCreators.completeConfiguration())
            self.onAppLoad()
            
        }
        
    }
    
    private func startApplicationReset() {
        
        //remove all subscribers
        self.storeManager.unsubscribeAll()
        //Even though we've unsubscribed, we're going to dispatch
        //the SignOut action to all the listeners before the action was submitted
        //allow the remaining subscribers to continue processing
        DispatchQueue.main.async {
            self.storeManager = nil
            self.applicationReset { (completed, error) in
                
                self.finishApplicationReset()
                
            }
        }
        
        
        
    }
    
    @objc
    public func printRefCount() {
        #if DEBUG
        if self.weakStore != nil {
            print("store ref count: \(CFGetRetainCount(self.weakStore))")
        }
        else {
            print("store ref count: 0")
        }
        #endif
    }
    
    @discardableResult
    open func initializeApplication(fromReset: Bool) -> Bool {
        
        self.persistentStoreSubscriber = RSStatePersistentStoreSubscriber(
            stateManagerDescriptors: self.stateManagerDescriptors,
            stateManagerGenerators: self.stateManagerGenerators
        )
        
        let middleware: [Middleware] = self.storeMiddleware.compactMap { $0.getMiddleware(appDelegate: self) }

        self.storeManager = RSStoreManager(
            initialState: self.persistentStoreSubscriber.loadState(),
            middleware: middleware
        )
        
        self.store.subscribe(self)
        
        self.weakStore = store
        self.printRefCount()
        
        self.taskBuilderStateHelper = RSTaskBuilderStateHelper(store: self.store)
        self.taskBuilder = RSTBTaskBuilder(
            stateHelper: self.taskBuilderStateHelper,
            elementGeneratorServices: self.elementGeneratorServices,
            stepGeneratorServices: self.stepGeneratorServices,
            answerFormatGeneratorServices: self.answerFormatGeneratorServices
        )
        
        self.stepTreeBuilder = RSStepTreeBuilder(
            stateHelper: self.taskBuilderStateHelper,
            nodeGeneratorServices: self.stepTreeNodeGenerators,
            elementGeneratorServices: self.elementGeneratorServices,
            stepGeneratorServices: self.stepGeneratorServices,
            answerFormatGeneratorServices: self.answerFormatGeneratorServices
        )
        
        
        self.printRefCount()
        
        self.store.subscribe(self.persistentStoreSubscriber)
        
        self.activityManager = RSActivityManager(stepTreeBuilder: self.stepTreeBuilder)
        self.layoutManager = RSLayoutManager(layoutGenerators: self.layoutGenerators)
        self.actionManager = RSActionManager(actionCreatorTransforms: self.actionCreatorTransforms)
        self.stateObjectManager = RSStateObjectManager(stateObjectTypes: self.stateObjectTypes)
        self.collectionViewCellManager = RSCollectionViewCellManager(cellGenerators: self.collectionViewCellGenerators)
        
        if notificationSupport {
            self.notificationManager = RSNotificationManager(store: self.store, notificationProcessors: self.notificationProcessors)
            self.store.subscribe(self.notificationManager!)
            RSNotificationManager.printPendingNotifications()
        }
        
        if self.locationSupport,
            let config = self.locationManagerConfig {
            
            self.locationManager = RSLocationManager(store: self.store, config: config)
            self.store.subscribe(self.locationManager!)
        }
        
        self.printRefCount()
        
        let pathManager = RSPathManager(pathGenerators: self.pathGenerators)
        let routeManager = RSRouteManager(routeGenerators: self.routeGenerators, pathManager: pathManager)
        self.routeManager = routeManager
        
        //set root view controller
        self.routingViewController = RSRoutingViewController(rootLayoutIdentifier: "ROOT", routeManager: routeManager, activityManager: self.activityManager, store: self.store)
        self.window!.rootViewController = self.routingViewController
        self.window!.makeKeyAndVisible()
        
        if self.feedbackEnabled() {
            
            self.feedbackViewController = RSFeedbackViewController(window: self.window!)

        }
        
        self.printRefCount()
        
        //function bindings need to go first in case they are used by routes
        let registerFunctionAction = RSActionCreators.registerFunction(identifier: "now") { state in
            return Date() as NSDate
        }

        self.store.dispatch(registerFunctionAction)
        
        self.store.dispatch(RSActionCreators.registerFunction(identifier: "config") { state in
            return self.chConfig?.rawValue as NSString?
        })
        
        self.openURLManager = RSOpenURLManager(openURLDelegates: self.openURLDelegates)
        
        self.printRefCount()
        
        self.storeInitialization(store: self.store!)
        self.initializeBackends()
        self.developmentInitialization()
        

        return true
    }
    
    open func developmentInitialization() {
        
    }
    
    open func feedbackEnabled() -> Bool {
        return false
    }
    
    open func storeInitialization(store: Store<RSState>) {
        
        self.loadState()
        self.loadActions()
        self.loadMeasures()
        self.loadActivities()
        self.loadLayouts()
        
        self.loadNotifications()
    }
    
    open func loadState() {
        
    }
    
    open func loadActions() {
        
    }
    
    open func loadMeasures() {
        
    }
    
    open func loadActivities() {
        
    }
    
    open func loadLayouts() {
        
    }
    
    open func loadNotifications() {
        
    }
    
    open func initializeBackends() {
        
    }
    
    open func onAppLoad() {
        
    }
    
    open func initConfiguration() -> RSConfiguration {
        return .development
    }
    
    
    open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.logger?.log(tag: RSApplicationDelegate.TAG, level: .info, message: "willFinishLaunchingWithOptions")
        
        if UserDefaults.standard.object(forKey: "FirstRun") == nil {
            UserDefaults.standard.set("1stRun", forKey: "FirstRun")
            UserDefaults.standard.synchronize()
            
            RSKeychainHelper.clearKeychain()
        }
        
        self.chConfig = self.initConfiguration()
        
        let initialzed = self.initializeApplication(fromReset: false)
        
        self.store?.dispatch(RSActionCreators.completeConfiguration())
        self.onAppLoad()
        
        return initialzed
    }
    
    //note that this is invoked after application didFinishLauchingWithOptions
    open func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.openURLManager.handleURL(app: app, url: url, options: options)
    }
    
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.logger?.log(tag: RSApplicationDelegate.TAG, level: .info, message: "didFinishLaunchingWithOptions")
        
        let window: UIWindow = self.window!
        let rootVC: RSRootViewController = window.rootViewController as! RSRootViewController
        rootVC.lockScreen()
        return true
    }

    open func applicationWillResignActive(_ application: UIApplication) {
        
        self.logger?.log(tag: RSApplicationDelegate.TAG, level: .info, message: "applicationWillResignActive")
        
        let state: RSState = self.store.state
        if RSStateSelectors.shouldShowPasscode(state) {
            // Hide content so it doesn't appear in the app switcher.

            let rootVC: RSRootViewController = self.window!.rootViewController as! RSRootViewController
            rootVC.setContentHidden(hidden: true)
            
        }
    }
    
    open func applicationDidEnterBackground(_ application: UIApplication) {
        
        self.logger?.log(tag: RSApplicationDelegate.TAG, level: .info, message: "applicationDidEnterBackground")
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    open func applicationWillEnterForeground(_ application: UIApplication) {
        
        self.logger?.log(tag: RSApplicationDelegate.TAG, level: .info, message: "applicationWillEnterForeground")
        
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        let rootVC: RSRootViewController = self.window!.rootViewController as! RSRootViewController
        rootVC.lockScreen()
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        
        self.logger?.log(tag: RSApplicationDelegate.TAG, level: .info, message: "applicationDidBecomeActive")
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Make sure that the content view controller is not hiding content
        
        let rootVC: RSRootViewController = self.window!.rootViewController as! RSRootViewController
        rootVC.setContentHidden(hidden: false)
    }
    
    open func applicationWillTerminate(_ application: UIApplication) {
        
        self.logger?.log(tag: RSApplicationDelegate.TAG, level: .info, message: "applicationWillTerminate")
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}



extension Store: RSActionManagerProvider {
    
    public func processAction(action: JSON, context: [String : AnyObject], store: Store<RSState>) {
        self.actionManager.processAction(action: action, context: context, store: store)
    }
    
    public func processActions(actions: [JSON], context: [String : AnyObject], store: Store<RSState>) {
        self.actionManager.processActions(actions: actions, context: context, store: store)
    }
    
    public var actionManager: RSActionManager! {
        return RSApplicationDelegate.appDelegate.actionManager
    }
    
    
}

