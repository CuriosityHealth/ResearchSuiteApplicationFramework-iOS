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

open class RSApplicationDelegate: UIResponder, UIApplicationDelegate {
    
    public var window: UIWindow?
    
    public var activityManager: RSActivityManager!
    
    public var storeManager: RSStoreManager!
    public var taskBuilderStateHelper: RSTaskBuilderStateHelper!
    public var taskBuilder: RSTBTaskBuilder!
    public var stepTreeBuilder: RSStepTreeBuilder!
    
    public var resultsProcessorFrontEnd: RSRPFrontEndService!
    public var persistentStoreSubscriber: RSStatePersistentStoreSubscriber!
    
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
        return []
    }
    
    open var stepTreeNodeGenerators: [RSStepTreeNodeGenerator.Type] {
        return [
            RSStepTreeElementListGenerator.self,
            RSStepTreeElementFileGenerator.self
        ]
    }
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //initialize store
        self.persistentStoreSubscriber = RSStatePersistentStoreSubscriber(
            protectedStorageManager: RSFileStateManager(filePath: "protected_state", fileProtection: Data.WritingOptions.completeFileProtectionUnlessOpen),
            unprotectedStorageManager: RSFileStateManager(filePath: "unprotected_state", fileProtection: Data.WritingOptions.noFileProtection)
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
        
        self.activityManager = RSActivityManager(store: self.store, taskBuilder: self.taskBuilder, stepTreeBuilder: self.stepTreeBuilder)
        
        
        
        self.store.subscribe(self.persistentStoreSubscriber)
        
        self.activityManager.delegate = self.window?.rootViewController
        
        return true
    }

}
