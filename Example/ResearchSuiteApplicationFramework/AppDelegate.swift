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

@UIApplicationMain
class AppDelegate: RSApplicationDelegate {
    
    

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        self.store?.dispatch(RSActionCreators.addMeasuresFromFile(fileName: "measures"))
        self.store?.dispatch(RSActionCreators.addActivitiesFromFile(fileName: "activities"))
        self.store?.dispatch(RSActionCreators.addStateValuesFromFile(fileName: "values"))
        self.store?.dispatch(RSActionCreators.addConstantsFromFile(fileName: "values"))
        self.store?.dispatch(RSActionCreators.addFunctionsFromFile(fileName: "values"))
        
        let registerFunctionAction = RSActionCreators.registerFunction(identifier: "isSignedIn") {
            return true as NSNumber
        }
        
        self.store?.dispatch(registerFunctionAction)
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    open override var stepGeneratorServices: [RSTBStepGenerator] {
        return super.stepGeneratorServices + [
            YADLFullStepGenerator(),
            YADLSpotStepGenerator()
        ]
    }
    
    open override var frontEndResultTransformers: [RSRPFrontEndTransformer.Type] {
        return [
            YADLFullRawRegex.self,
            YADLSpotRaw.self,
            YADLFullModerateOrHardIdentifiers.self,
            PSScore.self
        ]
    }
    
    open override var stepTreeNodeGenerators: [RSStepTreeNodeGenerator.Type] {
        return [
            YADLFullNodeGenerator.self
        ] + super.stepTreeNodeGenerators
    }


}

