//
//  RSActivityManagerDelegate.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit

protocol RSActivityManagerDelegate: NSObjectProtocol {
    
    var isPresenting: Bool { get }
    func tryToLaunchActivity(activityManager: RSActivityManager, uuid: UUID, activity: RSActivity) -> Bool

}
