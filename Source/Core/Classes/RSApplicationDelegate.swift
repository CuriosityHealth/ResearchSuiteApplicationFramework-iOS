//
//  RSApplicationDelegate.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ReSwift
import ResearchSuiteTaskBuilder
import ResearchSuiteResultsProcessor
import CoreLocation
import Gloss
import ResearchSuiteExtensions
import ResearchKit

open class RSApplicationDelegate: UIResponder, UIApplicationDelegate, ORKPasscodeDelegate, StoreSubscriber {
    
    public var window: UIWindow?
    private var rootNavController: RSRoutingNavigationController?
    
    public var activityManager: RSActivityManager!
    public var notificationManager: RSNotificationManager?
    public var locationManager: RSLocationManager?
    
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
            RSTBImageCaptureStepGenerator()
        ]
    }
    
    open var answerFormatGeneratorServices:  [RSTBAnswerFormatGenerator] {
        return [
            RSTBTextFieldStepGenerator(),
            RSTBIntegerStepGenerator(),
            RSTBTimePickerStepGenerator(),
            RSTBDatePickerStepGenerator(),
            RSTBScaleStepGenerator()
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
            RSScaleStepResult.self
        ]
    }
    
    open var stepTreeNodeGenerators: [RSStepTreeNodeGenerator.Type] {
        return [
            RSStepTreeElementListGenerator.self,
            RSStepTreeElementFileGenerator.self
        ]
    }
    
    open var layoutGenerators: [RSLayoutGenerator] {
        return [
            RSListLayoutGenerator(),
            RSTitleLayoutGenerator(),
            RSTabLayoutGenerator()
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
        return []
    }
    
    open var actionCreatorTransforms: [RSActionTransformer.Type] {
        return [
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
            RSActionSwitchTransformer.self
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
            RSArrayValueTransformer.self
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
    
    open var stateManagersFileName: String = "state"
    
    open var stateManagerDescriptors: [RSStateManagerDescriptor] {
        let selector: (JSON)-> [JSON]? = { "stateManagers" <~~ $0 }
        guard let json = RSHelpers.getJson(forFilename: self.stateManagersFileName) as? JSON,
            let jsonArray = selector(json) else {
                return []
        }
        
        return jsonArray.flatMap { RSStateManagerDescriptor(json: $0) }
    }
    
    open func newState(state: RSState) {

        if state.signOutRequested && !RSStateSelectors.isFetchingNotifications(state) {
            self.signOut(completed: { (completed, error) in
                
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
            
            if self.notificationSupport {
                self.notificationManager?.cancelNotifications()
                self.notificationManager = nil
            }
            
            if self.locationSupport {
                self.locationManager?.stopMonitoringRegions()
                self.locationManager = nil
            }
            
            self.layoutManager = nil
            
//            self.window?.rootViewController = UIViewController()
//            self.window?.makeKeyAndVisible()
//
//            self.rootNavController = nil
            
            self.openURLManager = nil
            
            
            //potentially clear the documents directory as well
            RSKeychainHelper.clearKeychain()
            
//            self.perform(#selector(self.printRefCount), with: nil, afterDelay: 5.0)
            
            self.initializeApplication(fromReset: true)
            
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
        if self.weakStore != nil {
            print("store ref count: \(CFGetRetainCount(self.weakStore))")
        }
        else {
            print("store ref count: 0")
        }
    }
    
    open func initializeApplication(fromReset: Bool) -> Bool {
        
        self.persistentStoreSubscriber = RSStatePersistentStoreSubscriber(
            stateManagerDescriptors: self.stateManagerDescriptors,
            stateManagerGenerators: self.stateManagerGenerators
        )
        
        let middleware: [Middleware] = self.storeMiddleware.flatMap { $0.getMiddleware(appDelegate: self) }

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
        
        //set root view controller
        self.rootNavController = RSRoutingNavigationController()
        self.rootNavController?.store = self.store
        self.rootNavController?.layoutManager = self.layoutManager
        self.rootNavController?.activityManager = self.activityManager
        self.rootNavController?.viewControllers = [UIViewController()]
        
        self.transition(toRootViewController: self.rootNavController!, animated: fromReset)
        
        self.printRefCount()
        
        //function bindings need to go first in case they are used by routes
        let registerFunctionAction = RSActionCreators.registerFunction(identifier: "now") {
            return Date() as NSDate
        }
        
        self.store.dispatch(registerFunctionAction)
        
        self.openURLManager = RSOpenURLManager(openURLDelegates: self.openURLDelegates)
        
        
        self.printRefCount()

        return true
    }
    
    open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if UserDefaults.standard.object(forKey: "FirstRun") == nil {
            UserDefaults.standard.set("1stRun", forKey: "FirstRun")
            UserDefaults.standard.synchronize()
            
            RSKeychainHelper.clearKeychain()
        }
        
        return self.initializeApplication(fromReset: false)
    }
    
    //note that this is invoked after application didFinishLauchingWithOptions
    open func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.openURLManager.handleURL(app: app, url: url, options: options)
    }
    
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        lockScreen()
        return true
    }
    
    // ------------------------------------------------
    // MARK: Passcode Display Handling
    // ------------------------------------------------
    
    private weak var passcodeViewController: UIViewController?
    
    /**
     Should the passcode be displayed. By default, if there isn't a catasrophic error,
     the user is registered and there is a passcode in the keychain, then show it.
     */
    open func shouldShowPasscode() -> Bool {
        return (self.passcodeViewController == nil) &&
            ORKPasscodeViewController.isPasscodeStoredInKeychain()
    }
    
    open func isPasscodePresented() -> Bool {
        return self.passcodeViewController != nil
    }
    
    private func instantiateViewControllerForPasscode() -> UIViewController? {
        return ORKPasscodeViewController.passcodeAuthenticationViewController(withText: nil, delegate: self)
    }
    
    /**
     Convenience method for presenting a modal view controller.
     */
    open func presentViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        self.topViewController()?.present(viewController, animated: animated, completion: completion)
    }
    
    open func topViewController() -> UIViewController? {
        guard let rootVC = self.window?.rootViewController else {
            return nil
        }
        var topViewController: UIViewController = rootVC
        while (topViewController.presentedViewController != nil) {
            topViewController = topViewController.presentedViewController!
        }
        return topViewController
    }
    
    open func transition(toRootViewController: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        if (animated) {
            let snapshot:UIView = (self.window?.snapshotView(afterScreenUpdates: true))!
            toRootViewController.view.addSubview(snapshot);
            
            self.window?.rootViewController = toRootViewController;
            
            UIView.animate(withDuration: 0.3, animations: {() in
                snapshot.layer.opacity = 0;
            }, completion: {
                (value: Bool) in
                snapshot.removeFromSuperview()
            })
        }
        else {
            window.rootViewController = toRootViewController
        }
    }
    
    
    public func lockScreen() {
        
        let state: RSState = self.store.state
        guard RSStateSelectors.shouldShowPasscode(state) else {
            return
        }
        
        
        
        let vc = ORKPasscodeViewController.passcodeAuthenticationViewController(withText: nil, delegate: self)
        
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        
        let uuid = UUID()
        self.store.dispatch(PresentPasscodeRequest(uuid: uuid, passcodeViewController: vc))
        
        self.window?.makeKeyAndVisible()
        
        presentViewController(vc, animated: false, completion: {
            self.store.dispatch(PresentPasscodeSuccess(uuid: uuid, passcodeViewController: vc))
        })
    }
    
    private func dismissPasscodeViewController(_ animated: Bool) {
        
        let state: RSState = self.store.state
        guard let passcodeViewController = RSStateSelectors.passcodeViewController(state) else {
            return
        }
        
        let uuid = UUID()
        self.store.dispatch(DismissPasscodeRequest(uuid: uuid, passcodeViewController: passcodeViewController))
        passcodeViewController.presentingViewController?.dismiss(animated: animated, completion: {
            self.store.dispatch(DismissPasscodeSuccess(uuid: uuid, passcodeViewController: passcodeViewController))
        })
    }
    
    private func resetPasscode() {
        
        let state: RSState = self.store.state
        guard let passcodeViewController = RSStateSelectors.passcodeViewController(state) else {
            return
        }
        
        self.signOut{ (signedOut, error) in
            passcodeViewController.presentingViewController?.dismiss(animated: false, completion: nil)
            // Dismiss the view controller unanimated
//            dismissPasscodeViewController(false)
        }
    }
    
    // MARK: ORKPasscodeDelegate
    
    open func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
        dismissPasscodeViewController(true)
    }
    
    open func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
        // Do nothing in default implementation
    }
    
    open func passcodeViewControllerForgotPasscodeTapped(_ viewController: UIViewController) {
        
        let title = "Reset Passcode"
        let message = "In order to reset your passcode, you'll need to log out of the app completely and log back in using your email and password."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            self.resetPasscode()
        })
        alert.addAction(logoutAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    open func setContentHidden(vc: UIViewController, contentHidden: Bool) {
        if let vc = vc.presentedViewController {
            vc.view.isHidden = contentHidden
        }
        
        vc.view.isHidden = contentHidden
    }
    
    open func applicationWillResignActive(_ application: UIApplication) {
        
        let state: RSState = self.store.state
        if RSStateSelectors.shouldShowPasscode(state) {
            // Hide content so it doesn't appear in the app switcher.
            if let vc = self.window?.rootViewController {
                self.setContentHidden(vc: vc, contentHidden: true)
            }
            
        }
    }
    
    open func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    open func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        lockScreen()
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Make sure that the content view controller is not hiding content
        if let vc = self.window?.rootViewController {
            self.setContentHidden(vc: vc, contentHidden: false)
        }
    }
    
    open func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

