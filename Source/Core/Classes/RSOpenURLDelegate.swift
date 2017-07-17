//
//  RSOpenURLDelegate.swift
//  Pods
//
//  Created by James Kizer on 7/17/17.
//
//

import UIKit

public protocol RSOpenURLDelegate: NSObjectProtocol {
    
    func handleURL(app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool

}
