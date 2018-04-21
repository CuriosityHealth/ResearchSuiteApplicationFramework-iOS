//
//  RSNotificationPermissionRequestStepDelegate.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/20/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import UserNotifications

open class RSNotificationPermissionRequestStepDelegate: RSPermissionRequestStepDelegate {
    
    public func permissionRequestViewControllerDidLoad(viewController: RSPermissionRequestStepViewController) {
        
    }
    
    public func requestPermissions(completion: @escaping ((Bool, Error?) -> ())) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            completion(granted, error)
        }
    }
    
    public func alertController(granted: Bool, error: Error) -> UIAlertController {
        let alertController = UIAlertController(title: "Grant Error", message: "Unable to show notifications. You can update this in your settings.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            
        }
        
        alertController.addAction(okAction)
        return alertController
        
    }
    
}
