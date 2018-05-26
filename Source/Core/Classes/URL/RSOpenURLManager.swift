//
//  RSOpenURLManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/17/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchSuiteExtensions

open class RSOpenURLManager: NSObject {
    
    var openURLDelegates: [RSOpenURLDelegate]
    
    public init(
        openURLDelegates: [RSOpenURLDelegate]?
        ) {
        self.openURLDelegates = openURLDelegates ?? []
        super.init()
    }
    
    open func addDelegate(delegate: RSOpenURLDelegate) {
        self.openURLDelegates = self.openURLDelegates + [delegate]
    }
    
    open func removeDelegate(delegate: RSOpenURLDelegate) {
        self.openURLDelegates = self.openURLDelegates.filter { $0.isEqual(delegate) }
    }
    
    open func handleURL(app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let delegates = self.openURLDelegates
        
        guard let appDelegate = app.delegate as? RSApplicationDelegate else {
            return false
        }
        
        for delegate in delegates {
            let context: [String: AnyObject] = ["store": appDelegate.store]
            let handled = delegate.handleURL(app: app, url: url, options: options, context: context)
            if handled { return true }
        }
        return false
    }

}
