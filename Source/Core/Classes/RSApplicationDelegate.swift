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

open class RSApplicationDelegate: UIResponder, UIApplicationDelegate {
    
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
            RSTBLocationStepGenerator()
        ]
    }
    
    open var answerFormatGeneratorServices:  [RSTBAnswerFormatGenerator] {
        return [
            RSTBTextFieldStepGenerator(),
            RSTBIntegerStepGenerator(),
            RSTBTimePickerStepGenerator(),
            RSTBDatePickerStepGenerator()
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
            RSBooleanStepResult.self
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
    
    open var persistentStoreObjectDecodingClasses: [Swift.AnyClass] {
        return [
            NSDictionary.self,
            NSArray.self,
            NSDate.self,
            CLLocation.self,
            NSDateComponents.self
        ]
    }
    
    open var openURLDelegates: [RSOpenURLDelegate] {
        return []
    }
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //initialize store
        self.persistentStoreSubscriber = RSStatePersistentStoreSubscriber(
            protectedStorageManager: RSFileStateManager(
                filePath: "protected_state",
                fileProtection: Data.WritingOptions.completeFileProtectionUnlessOpen,
                decodingClasses: self.persistentStoreObjectDecodingClasses
            ),
            unprotectedStorageManager: RSFileStateManager(
                filePath: "unprotected_state",
                fileProtection: Data.WritingOptions.noFileProtection,
                decodingClasses: self.persistentStoreObjectDecodingClasses
            )
        )
        
        self.storeManager = RSStoreManager(initialState: self.persistentStoreSubscriber.loadState())
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
}
