//
//  RSApplicationDelegate.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ReSwift

open class RSApplicationDelegate: UIResponder, UIApplicationDelegate {
    
    public var window: UIWindow?
    
    public var storeManager: RSStoreManager?
    
    public var store: Store<RSState>? {
        return storeManager?.store
    }
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //initialize store
        self.storeManager = RSStoreManager(initialState: nil)
        
        return true
    }

}
