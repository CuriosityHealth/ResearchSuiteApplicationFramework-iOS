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
    case is_testing = "is_testing"
    case usability_testing = "usability_testing"
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
    
    public var localizationHelper: RSTBLocalizationHelper = RSTBLocalizationHelper()
    
    public var activityManager: RSActivityManager!
    public var measureManager: RSMeasureManager!
    public var actionManager: RSActionManager!
    public var valueManager: RSValueManager!
    public var predicateManager: RSPredicateManager!
    public var notificationManager: RSNotificationManager?
    public var locationManager: RSLocationManager?
    public var routeManager: RSRouteManager!
    public var collectionViewCellManager: RSCollectionViewCellManager!
    public var stateObjectManager: RSStateObjectManager!
    public var collectionDataSourceManager: RSCollectionDataSourceManager!
    public var outputDirectoryFileStorage: RSFileStorage!
    
    public var scheduler: RSScheduler?
    
    //TODO:
    public var storeManager: RSStoreManager?
//    public var taskBuilderStateHelper: RSTaskBuilderStateHelper!
//    public var taskBuilder: RSTBTaskBuilder!
//    public var stepTreeBuilder: RSStepTreeBuilder!
    
    public var resultsProcessorFrontEnd: RSRPFrontEndService!
    public var persistentStoreSubscriber: RSStatePersistentStoreSubscriber!
    
    public var layoutManager: RSLayoutManager!
    
    public var openURLManager: RSOpenURLManager!
    
    public static var appDelegate: RSApplicationDelegate! {
        return UIApplication.shared.delegate as! RSApplicationDelegate
    }
    
    public func color(name: String) -> UIColor? {
        if let state = RSApplicationDelegate.appDelegate.store?.state,
            let color: UIColor = RSStateSelectors.getValueInCombinedState(state, for: name) as? UIColor {
            return color
        }
        else {
            return nil
        }
    }
    
    public var store: Store<RSState>? {
        return self.storeManager?.store
    }
    
    public var appBundleVersion: String {
        return Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    }
    
    public var appVersion: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    public var documentsPath: String {
        return NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory,
            FileManager.SearchPathDomainMask.userDomainMask,
            true
            ).first!
    }
    
    open func passcodeScreenText(state: RSState) -> String? {
        return nil
    }
    
    weak var weakStore: Store<RSState>?
    
    private var lastState: RSState?
    
    open var logger: RSLogger?
    
    open var applicationTheme: RSApplicationTheme? {
        return nil
    }
    
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
            RSTBCountdownStepGenerator(),
            RSTBDateTimePickerStepGenerator(),
            RSTBTimeIntervalStepGenerator(),
            RSTextInstructionStepGenerator(),
            RSTBVideoInstructionStepGenerator(),
            RSEnhancedTimePickerStepGenerator(),
            RSEnhancedDateTimePickerStepGenerator(),
            RSEnhancedDayOfWeekChoiceStepGenerator(),
            RSFullScreenImageStepGenerator()
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
            RSEnhancedScaleStepGenerator(),
            RSTBBooleanStepGenerator(),
            RSTBDateTimePickerStepGenerator(),
            RSTBTimeIntervalStepGenerator()
        ]
    }
    
    open var defaultStepResultGeneratorServices: [RSDefaultStepResultGenerator.Type] {
        return [
            RSTextFieldDefaultStepResultGenerator.self
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
            RSScaleStepResult.self,
            RSSumResult.self
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
            RSWebLayout.self,
            RSDashboardLayout.self,
            RSNewDashboardLayout.self,
            RSLicenseLayout.self,
            RSPDFViewerLayout.self
        ]
    }
    
    open var pathGenerators: [RSPathGenerator.Type] {
        return [
            RSExactPath.self,
            RSPrefixPath.self,
            RSParamPath.self,
            RSBrowserPath.self
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
    
    open var notificationResponseHandlers: [RSNotificationResponseHandler.Type] {
        return []
    }
    
    open var notificationSupport: Bool {
        return true
    }
    
    open var locationSupport: Bool {
        return false
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
            RSDefinedAction.self,
            RSReloadConfigActionTransformer.self,
            RSEmailCurrentLogActionTransformer.self
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
            RSPrettyPrintJSONTransformer.self,
            RSTemplatedMarkdownTransformer.self,
            RSMostRecentDateTransformer.self,
            RSStartOfDayValueTransformer.self,
            RSExpressionValueTransformer.self,
            RSDataSourceCollectionValueTransformer.self,
            RSJSONValueTransformer.self,
            RSDatapointValueTransformer.self,
            RSFetchDatapointValueTransformer.self,
            RSSelectorValueTransformer.self,
            RSDatapointHeaderValueTransformer.self,
            RSMapValueTransformer.self,
            RSFirstValueTransformer.self,
            RSFontValueTransformer.self,
            RSCollectionCountValueTransformer.self,
            RSPredicateValueTransformer.self,
            RSSwitchValueTransform.self
        ]
    }
    
    open var collectionViewCellGenerators: [RSCollectionViewCellGenerator.Type] {
        return [
            RSBasicCollectionViewCell.self,
//            RSCardCollectionViewCell.self,
            RSBasicCardCollectionViewCell.self,
            RSTextCardCollectionViewCell.self,
            RSMarkdownCardCollectionViewCell.self
        ]
    }
    
    open var collectionDataSourceGenerators: [RSCollectionDataSourceGenerator.Type] {
        return [
            RSCompositeCollectionDataSource.self,
            RSDatabaseCollectionDataSourceGenerator.self
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
    
    open var debugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
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
        fatalError()
        return []
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
        
        
        //We've decided to only reload config when we're not in the middle of doing a bunch of other stuff, including:
        // - fetching notifications
        // - presenting / dismissing passcode
        // - presenting / dismissing activities (including processing their actions)
        // we should also prevent us from doing so while processing actions associated with the activity. it appears that this is happening
        // since we don't dismiss the activity until the actions have been processed
        // for now, if there are activities queued up,
        if self.debugMode
            && state.reloadConfigRequested
            && !RSStateSelectors.isFetchingNotifications(state)
            && !RSStateSelectors.isPresentingPasscode(state)
            && !RSStateSelectors.isDismissingPasscode(state)
            && !RSStateSelectors.isPasscodePresented(state)
            && !RSStateSelectors.isPresenting(state)
            && !RSStateSelectors.isDismissing(state)
            && RSStateSelectors.presentedActivity(state) == nil
            && RSStateSelectors.getQueuedActivities(state).count == 0
            && RSStateSelectors.isConfigurationCompleted(state) {
            
            debugPrint("####!!!! Reloading Config")
            
            self.reloadConfig()
            
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
    
    
    //we need to make sure that we only do this at certain points of time
    public func reloadConfig() {
        self.persistentStoreSubscriber = nil
        
        self.activityManager = nil
        self.measureManager = nil
        self.actionManager = nil
        self.valueManager = nil
        self.predicateManager = nil
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

        self.initializeApplication(fromReset: true)
        
        self.store?.dispatch(RSActionCreators.completeConfiguration())
        self.onAppLoad()
    }
    
    private func finishApplicationReset() {
        
        //clear persistent store subscriber
        self.persistentStoreSubscriber.clearState { (completd, error) in
            
            self.outputDirectoryFileStorage.delete(completion: { (fileStorageError) in
                
                self.outputDirectoryFileStorage = nil
                
                self.persistentStoreSubscriber = nil
                
                self.activityManager = nil
                self.measureManager = nil
                self.actionManager = nil
                self.valueManager = nil
                self.predicateManager = nil
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
                
            })
            
        }
        
    }
    
    private func startApplicationReset() {
        
        //remove all subscribers
        self.storeManager?.unsubscribeAll()
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
        if self.debugMode {
            if self.weakStore != nil {
                print("store ref count: \(CFGetRetainCount(self.weakStore))")
            }
            else {
                print("store ref count: 0")
            }
        }
    }
    
    @discardableResult
    open func initializeApplication(fromReset: Bool) -> Bool {
        
        self.persistentStoreSubscriber = RSStatePersistentStoreSubscriber(
            stateManagerDescriptors: self.stateManagerDescriptors,
            stateManagerGenerators: self.stateManagerGenerators
        )
        
        let middleware: [Middleware] = self.storeMiddleware.compactMap { $0.getMiddleware(appDelegate: self) }

        let storeManager = RSStoreManager(
            initialState: self.persistentStoreSubscriber.loadState(),
            middleware: middleware
        )
        
        self.storeManager = storeManager
        
        let store = storeManager.store
        
        store.subscribe(self)
        
        self.weakStore = store
        self.printRefCount()
        
//        self.taskBuilderStateHelper = RSTaskBuilderStateHelper(store: self.store)
//
//        self.taskBuilder = RSTBTaskBuilder(
//            stateHelper: self.taskBuilderStateHelper,
//            elementGeneratorServices: self.elementGeneratorServices,
//            stepGeneratorServices: self.stepGeneratorServices,
//            answerFormatGeneratorServices: self.answerFormatGeneratorServices
//        )
//
//        self.stepTreeBuilder = RSStepTreeBuilder(
//            stateHelper: self.taskBuilderStateHelper,
//            nodeGeneratorServices: self.stepTreeNodeGenerators,
//            elementGeneratorServices: self.elementGeneratorServices,
//            stepGeneratorServices: self.stepGeneratorServices,
//            answerFormatGeneratorServices: self.answerFormatGeneratorServices
//        )
        
        
        self.printRefCount()
        
        store.subscribe(self.persistentStoreSubscriber)
        
        self.activityManager = RSActivityManager()
        self.measureManager = RSMeasureManager()
        self.layoutManager = RSLayoutManager(layoutGenerators: self.layoutGenerators)
        self.actionManager = RSActionManager(actionCreatorTransforms: self.actionCreatorTransforms)
        self.valueManager = RSValueManager(valueTransforms: self.valueTransforms)
        self.predicateManager = RSPredicateManager()
        self.stateObjectManager = RSStateObjectManager(stateObjectTypes: self.stateObjectTypes)
        self.collectionViewCellManager = RSCollectionViewCellManager(cellGenerators: self.collectionViewCellGenerators)
        self.collectionDataSourceManager = RSCollectionDataSourceManager(collectionDataSourceGenerators: self.collectionDataSourceGenerators)
        
        self.outputDirectoryFileStorage = RSFileStorage(storageDirectory: "TaskOutputStorage", storageDirectoryFileProtection: .completeUnlessOpen, logger: self.logger)
        
        if notificationSupport {
            self.notificationManager = RSNotificationManager(
                store: store,
                notificationResponseHandlers: self.notificationResponseHandlers,
                legacySupport: false,
                notificationProcessors: self.notificationProcessors
            )
            store.subscribe(self.notificationManager!)
            if self.debugMode {
                RSNotificationManager.printPendingNotifications()
            }
        }
        
        if self.locationSupport,
            let config = self.locationManagerConfig {
            
            self.locationManager = RSLocationManager(store: store, config: config)
            store.subscribe(self.locationManager!)
        }
        
        self.printRefCount()
        
        let pathManager = RSPathManager(pathGenerators: self.pathGenerators)
        let routeManager = RSRouteManager(routeGenerators: self.routeGenerators, pathManager: pathManager)
        self.routeManager = routeManager
        
        //set root view controller
        self.routingViewController = RSRoutingViewController(rootLayoutIdentifier: "ROOT", routeManager: routeManager, activityManager: self.activityManager, store: store)
        self.window!.rootViewController = self.routingViewController
        self.window!.makeKeyAndVisible()
        
        if self.feedbackEnabled() {
            
            self.feedbackViewController = RSFeedbackViewController(window: self.window!)

        }
        
        self.printRefCount()
        
       
        
        self.openURLManager = RSOpenURLManager(openURLDelegates: self.openURLDelegates)
        
        self.printRefCount()
        
        self.storeInitialization(store: self.store!)
        
        //function bindings need to go first in case they are used by routes
        let registerFunctionAction = RSActionCreators.registerFunction(identifier: "now") { state in
            return Date() as NSDate
        }
        
        store.dispatch(registerFunctionAction)
        
        let calendar = Calendar.current
        let registerToadyAction = RSActionCreators.registerFunction(identifier: "startOfToday") { state in
            return calendar.startOfDay(for: Date()) as NSDate
        }
        
        store.dispatch(registerToadyAction)
        
        store.dispatch(RSActionCreators.registerFunction(identifier: "config") { state in
            return self.chConfig?.rawValue as NSString?
        })
        
        
        self.initializeBackends()
        self.developmentInitialization()
        

        return true
    }
    
    open func configInitialization(store: Store<RSState>) {
        
    }
    
    open func appURLScheme() -> String? {
        guard let infoPlist = Bundle.main.infoDictionary,
            let urlTypes = infoPlist["CFBundleURLTypes"] as? NSArray,
            let first = urlTypes.firstObject as? [String: Any],
            let urlSchemes = first["CFBundleURLSchemes"] as? NSArray,
            let urlScheme = urlSchemes.firstObject as? String else {
                return nil
        }
        return urlScheme
    }
    
    open func developmentInitialization() {
        
    }
    
    open func feedbackEnabled() -> Bool {
        return false
    }
    
    open func reloadStore(store: Store<RSState>) {
        //remove everything
        //state
        //actions
        //measures
        //activities
        //layouts
        //notifications
        
        self.storeInitialization(store: store)
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
    
    open func generateOutputDirectory(uuid: UUID = UUID()) -> URL {
        
        let defaultFileManager = FileManager.default
        // Create a directory based on the `taskRunUUID` to store output from the task.
        let outputDirectory = self.outputDirectoryFileStorage.storageDirectory.appendingPathComponent(uuid.uuidString)
        
        do {
            try defaultFileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
            return outputDirectory
        }
        catch let error as NSError {
            fatalError("The output directory \(outputDirectory) could not be created. Error: \(error.localizedDescription)")
        }
        
        return self.outputDirectoryFileStorage.storageDirectory.appendingPathComponent(UUID().uuidString)
    }
    
    static func shouldConfirmCancelDefault() -> Bool {
        return self.appDelegate.shouldConfirmCancelDefault()
    }
    
    open func shouldConfirmCancelDefault() -> Bool {
        return true
    }
    
    open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        if #available(iOS 13.0, *) { // disable dark mode
            window?.overrideUserInterfaceStyle = .light
        }
            
        self.logger?.log(tag: RSApplicationDelegate.TAG, level: .info, message: "willFinishLaunchingWithOptions")
        
        if UserDefaults.standard.object(forKey: "FirstRun") == nil {
            UserDefaults.standard.set("1stRun", forKey: "FirstRun")
            UserDefaults.standard.synchronize()
            
            RSKeychainHelper.clearKeychain()
        }
        
        self.chConfig = self.initConfiguration()
        
        let initialzed = self.initializeApplication(fromReset: false)
        
        self.store?.dispatch(RSActionCreators.completeConfiguration())
        
        if let windowTintColor = self.applicationTheme?.windowTintColor {
            self.window?.tintColor = windowTintColor
        }
        
        self.onAppLoad()
        
        return initialzed
    }
    
    //note that this is invoked after application didFinishLauchingWithOptions
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //first check to see if this is a routable url
        if let routingVC = self.routingViewController,
            let appURLScheme = self.appURLScheme(),
            let store = self.store,
            routingVC.canRoute(newPath: url.absoluteString.replacingOccurrences(of: "\(appURLScheme)://", with: ""), state: store.state)
            {
            let action = RSActionCreators.requestPathChange(path: url.absoluteString.replacingOccurrences(of: "\(appURLScheme)://", with: ""))
            store.dispatch(action)
            return true
        }
        else {
            return self.openURLManager.handleURL(app: app, url: url, options: options)
        }
        
    }
    
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.logger?.log(tag: RSApplicationDelegate.TAG, level: .info, message: "didFinishLaunchingWithOptions")
        
        let window: UIWindow = self.window!
        let rootVC: RSRootViewController = window.rootViewController as! RSRootViewController
        rootVC.lockScreen()
        return true
    }
    
    open func applicationWillResignActive(_ application: UIApplication) {
        
        self.logger?.log(tag: RSApplicationDelegate.TAG, level: .info, message: "applicationWillResignActive")
        
        //the issue here is that every time the system presents an alert, we resign active
        //this includes things like the facetime alert
        //maybe check to see if the passcode ivew controller is presented
//        let rootVC: RSRootViewController = self.window!.rootViewController as! RSRootViewController
//        rootVC.setContentHidden(hidden: true)
        
        
        
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        
        self.logger?.log(tag: RSApplicationDelegate.TAG, level: .info, message: "applicationDidBecomeActive")
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Make sure that the content view controller is not hiding content
        
        
        //we become active active after any system alert is presented...
        //for example, if we present the facetime system alert during passcode, we come here after
        //the passcode has been dismissed
        //this creates a problem as we would only want to present the passcode if we are NOT
        //coming back from a system alert
        //essentially, we would only want to do this if content is hiddedn
        
//        let rootVC: RSRootViewController = self.window!.rootViewController as! RSRootViewController
//        rootVC.setContentHidden(hidden: false)
        
    }
    
    open func applicationDidEnterBackground(_ application: UIApplication) {
        
        self.logger?.log(tag: RSApplicationDelegate.TAG, level: .info, message: "applicationDidEnterBackground")
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if let state = self.store?.state,
            !RSStateSelectors.isPresentingPasscode(state)
                && !RSStateSelectors.isDismissingPasscode(state)
                && !RSStateSelectors.isPasscodePresented(state) {
            //do this conditionally based on an alert...
            let rootVC: RSRootViewController = self.window!.rootViewController as! RSRootViewController
            //content gets sent to not hidden via the passcode view controller dismiss
            rootVC.setContentHidden(hidden: true)
        }
        
    }
    
    open func applicationWillEnterForeground(_ application: UIApplication) {
        
        self.logger?.log(tag: RSApplicationDelegate.TAG, level: .info, message: "applicationWillEnterForeground")
        
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//        let rootVC: RSRootViewController = self.window!.rootViewController as! RSRootViewController
//        rootVC.lockScreen()
        
        if let state = self.store?.state,
            state.contentHidden == true {
            let rootVC: RSRootViewController = self.window!.rootViewController as! RSRootViewController
            rootVC.lockScreen()
        }
        
        //reload schedule
        //can we do this, or would it be better to set a flag in the state and reload when convenient?
        self.scheduler?.reloadSchedule(state: nil)
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

extension RSApplicationDelegate {
    public class func localizedString(_ string: String) -> String {
        return self.appDelegate.localizationHelper.localizedString(string)
    }
    
    public class func localizedString(_ string: String?) -> String? {
        return self.appDelegate.localizationHelper.localizedString(string)
    }
    
    public class func preferredLanguage() -> String {
        let preferredLanguage = Locale.preferredLanguages.first
        return preferredLanguage!
    }
}
