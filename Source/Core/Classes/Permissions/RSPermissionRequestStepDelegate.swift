//
//  RSPermissionRequestStepDelegate.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 12/20/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit

public protocol RSPermissionRequestStepDelegate {
    
    func permissionRequestViewControllerDidLoad(viewController: RSPermissionRequestStepViewController)
    func requestPermissions(completion: @escaping ((Bool, Error?) -> ()))
    func alertController(granted: Bool, error: Error) -> UIAlertController
    
}
