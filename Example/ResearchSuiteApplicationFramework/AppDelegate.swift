//
//  AppDelegate.swift
//  ResearchSuiteApplicationFramework
//
//  Created by jdkizer9 on 06/23/2017.
//  Copyright (c) 2017 jdkizer9. All rights reserved.
//

import UIKit
import ResearchSuiteApplicationFramework
import ResearchSuiteTaskBuilder
import ResearchSuiteResultsProcessor
import sdlrkx
import ResearchSuiteExtensions
import Gloss

@UIApplicationMain
class AppDelegate: RSApplicationDelegate {
    
    override func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if UserDefaults.standard.object(forKey: "FirstRun") == nil {
            UserDefaults.standard.set("1stRun", forKey: "FirstRun")
            UserDefaults.standard.synchronize()
            
            RSKeychainHelper.clearKeychain()
        }
        
        let superLaunched = super.application(application, willFinishLaunchingWithOptions: launchOptions)
        if !superLaunched {
            return false
        }
        
        //note that we can add 
        
        self.store?.dispatch(RSActionCreators.addMeasuresFromFile(fileName: "measures"))
        self.store?.dispatch(RSActionCreators.addActivitiesFromFile(fileName: "activities"))
        self.store?.dispatch(RSActionCreators.addStateValuesFromFile(fileName: "values"))
        self.store?.dispatch(RSActionCreators.addConstantsFromFile(fileName: "values"))
        self.store?.dispatch(RSActionCreators.addFunctionsFromFile(fileName: "values"))
        
        
        //function bindings need to go first in case they are used by routes
        let registerFunctionAction = RSActionCreators.registerFunction(identifier: "isSignedIn") {
            return true as NSNumber
        }
        
        self.store?.dispatch(registerFunctionAction)
        
        
        self.store?.dispatch(RSActionCreators.addLayoutsFromFile(fileName: "layouts"))
        self.store?.dispatch(RSActionCreators.addRoutesFromFile(fileName: "routes"))
        
        return true
    }
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        let superLaunched = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        if !superLaunched {
            return false
        }
        
        //this will end up starting the persistence manager listening
        self.store?.dispatch(RSActionCreators.completeConfiguration())
        return true
    }
    
    override open var stateManagerDescriptors: [RSStateManagerDescriptor] {
        let selector: (JSON)-> [JSON]? = { "stateManagers" <~~ $0 }
        guard let json = RSHelpers.getJson(forFilename: "values") as? JSON,
            let jsonArray = selector(json) else {
                return []
        }
        
        return jsonArray.flatMap { RSStateManagerDescriptor(json: $0) }
    }

    open override var stepGeneratorServices: [RSTBStepGenerator] {
        return super.stepGeneratorServices + [
            YADLFullStepGenerator(),
            YADLSpotStepGenerator(),
            PAMStepGenerator()
        ]
    }
    
    open override var frontEndResultTransformers: [RSRPFrontEndTransformer.Type] {
        return [
            YADLFullRawRegex.self,
            YADLSpotRaw.self,
            YADLFullModerateOrHardIdentifiers.self,
            PSScore.self,
            PSSRaw.self,
            DemographicsResult.self
        ] + super.frontEndResultTransformers
    }
    
    open override var stepTreeNodeGenerators: [RSStepTreeNodeGenerator.Type] {
        return [
            YADLFullNodeGenerator.self
        ] + super.stepTreeNodeGenerators
    }


}

