//
//  RSLayoutViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
