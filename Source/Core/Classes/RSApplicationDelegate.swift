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

open class RSApplicationDelegate: UIResponder, UIApplicationDelegate, ORKPasscodeDelegate {
    
    public var window: UIWindow?
    private var rootNavController: RSRoutingNavigationController!
    
    public var activityManager: RSActivityManager!
    
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
            RSSingleChoiceStepResult.self
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
            RSResetStateManagerActionTransformer.self
        ]
    }
    
    open var storeMiddleware: [RSMiddlewareProvider.Type] {
        #if DEBUG
            return [
                RSLoggingMiddleware.self,
                RSSendResultToServerMiddleware.self
            ]
        #else
            return [
                RSSendResultToServerMiddleware.self
            ]
        #endif
        
    }
    
    open var stateManagerGenerators: [RSStateManagerGenerator.Type] {
        return [
            RSFileStateManager.self
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
    
    open func signOut(completed: (Bool, Error?) -> Swift.Void ) {
        completed(true, nil)
    }
    
    open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        self.persistentStoreSubscriber = RSStatePersistentStoreSubscriber(
            stateManagerDescriptors: self.stateManagerDescriptors,
            stateManagerGenerators: self.stateManagerGenerators
        )
        
        let middleware: [Middleware] = self.storeMiddleware.map { $0.getMiddleware(appDelegate: self) }
        
        self.storeManager = RSStoreManager(
            initialState: self.persistentStoreSubscriber.loadState(),
            middleware: middleware
        )
        
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
        
        self.store.subscribe(self.persistentStoreSubscriber)
        
        self.activityManager = RSActivityManager(stepTreeBuilder: self.stepTreeBuilder)
        self.layoutManager = RSLayoutManager(layoutGenerators: self.layoutGenerators)
        
        //set root view controller
        self.rootNavController = RSRoutingNavigationController()
        self.rootNavController.store = self.store
        self.rootNavController.layoutManager = self.layoutManager
        self.rootNavController.activityManager = self.activityManager
        self.rootNavController.viewControllers = [UIViewController()]
        
        self.window?.rootViewController = self.rootNavController
        
        //function bindings need to go first in case they are used by routes
        let registerFunctionAction = RSActionCreators.registerFunction(identifier: "now") {
            return Date() as NSDate
        }
        
        self.store.dispatch(registerFunctionAction)
        
        self.openURLManager = RSOpenURLManager(openURLDelegates: self.openURLDelegates)
        
        return true
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
        
        window?.makeKeyAndVisible()
        
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
        
        self.signOut{ (signedOut, error) in
            // Dismiss the view controller unanimated
            dismissPasscodeViewController(false)
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

