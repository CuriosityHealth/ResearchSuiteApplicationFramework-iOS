//
//  RSOpenURLManager.swift
//  Pods
//
//  Created by James Kizer on 7/17/17.
//
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
        for delegate in delegates {
            let handled = delegate.handleURL(app: app, url: url, options: options)
            if handled { return true }
        }
        return false
    }

}
