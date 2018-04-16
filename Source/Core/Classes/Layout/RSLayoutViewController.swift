//
//  RSLayoutViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
//

import UIKit

public protocol RSLayoutViewController {
    
    //these should be unique!!!
    var identifier: String! { get }
    var matchedRoute: RSMatchedRoute! { get }
    var layout: RSLayout! { get }
    var viewController: UIViewController! { get }
    var parentLayoutViewController: RSLayoutViewController! { get }
    
    func present(matchedRoutes:[RSMatchedRoute], animated: Bool, state: RSState, completion: ((RSLayoutViewController?, Error?) -> Swift.Void)?)
    
    //it's unclear if we actually need this, but let's refactor to remove the completion block
    //that's one less thing for the clients to mess up
    func updateLayout(matchedRoute: RSMatchedRoute, state: RSState)
    
    func layoutDidLoad()
    func layoutDidAppear(initialAppearance: Bool)
    
    func backTapped()
}
