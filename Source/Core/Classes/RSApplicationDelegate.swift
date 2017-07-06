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

open class RSApplicationDelegate: UIResponder, UIApplicationDelegate, RSRouterDelegate {
    
    public var window: UIWindow?
    private var rootNavController: UINavigationController!
    
    public var activityManager: RSActivityManager!
    
    public var storeManager: RSStoreManager!
    public var taskBuilderStateHelper: RSTaskBuilderStateHelper!
    public var taskBuilder: RSTBTaskBuilder!
    public var stepTreeBuilder: RSStepTreeBuilder!
    
    public var resultsProcessorFrontEnd: RSRPFrontEndService!
    public var persistentStoreSubscriber: RSStatePersistentStoreSubscriber!
    
    public var layoutManager: RSLayoutManager!
    public var router: RSRouter!
    
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
            RSTitleLayoutGenerator()
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
        
        self.activityManager = RSActivityManager(store: self.store, taskBuilder: self.taskBuilder, stepTreeBuilder: self.stepTreeBuilder)
        
        self.store.subscribe(self.persistentStoreSubscriber)
        
        self.layoutManager = RSLayoutManager(layoutGenerators: self.layoutGenerators)
        
        self.router = RSRouter(
            store: self.store,
            layoutManager: self.layoutManager,
            delegate: self
        )
        
        self.store.subscribe(self.router)
        
        //set root view controller
        self.rootNavController = UINavigationController()
        self.window?.rootViewController = self.rootNavController
        self.activityManager.setDelegate(delegate: self.rootNavController)
        
        debugPrint(self.rootNavController)
        
        //function bindings need to go first in case they are used by routes
        let registerFunctionAction = RSActionCreators.registerFunction(identifier: "now") {
            return Date() as NSDate
        }
        
        self.store.dispatch(registerFunctionAction)
        
        return true
    }
    
    open func presentLayout(viewController: UIViewController, completion: ((Bool) -> Swift.Void)?) {
        self.transition(toRootViewController: viewController, animated: true, completion: { presented in
            completion?(presented)
        })
    }
    
    /**
     Convenience method for transitioning to the given view controller as the nav controller
     rootViewController.
     */
    
    //there is a bug when we are presenting a modal view controller and we reset the rootViewController
    open func transition(toRootViewController: UIViewController, animated: Bool, completion: ((Bool) -> Swift.Void)? = nil) {
        if (animated) {
            let snapshot:UIView = (self.window?.snapshotView(afterScreenUpdates: true))!

            
            //this causes viewdidLoad for toRootViewController to be called
            //if this is a layout view controller, its actions will be executed
//            toRootViewController.view.addSubview(snapshot);
            
            self.rootNavController.viewControllers = [toRootViewController]
            toRootViewController.view.addSubview(snapshot)
            
            UIView.animate(withDuration: 0.3, animations: {() in
                snapshot.layer.opacity = 0;
            }, completion: {
                (value: Bool) in
                snapshot.removeFromSuperview()
                completion?(value)
            })
        }
        else {
            self.rootNavController.viewControllers = [toRootViewController]
            completion?(true)
        }

    }

}
