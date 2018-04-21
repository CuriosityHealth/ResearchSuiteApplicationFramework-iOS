//
//  RSTabBarNavigationViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/15/18.
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

open class RSTabBarNavigationViewController: UIViewController {

    public let identifier: String
    public var rootViewController: UIViewController!
    public var tabPath: String!
    public var parentMatchedRoute: RSMatchedRoute
    
    public init(identifier: String, viewController: UIViewController, parentMatchedRoute: RSMatchedRoute) {
        
        self.identifier = identifier
        self.parentMatchedRoute = parentMatchedRoute
        
        super.init(nibName: nil, bundle: nil)
        
        self.addChildViewController(viewController)
        viewController.view.frame = self.view.bounds
        self.view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
        self.rootViewController = viewController
        
        self.parentMatchedRoute = parentMatchedRoute
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    public func setPath(path: String) {
        
        //remove prefix of match
        //also remove more porentially
        var relativePath = path.replacingOccurrences(of: self.parentMatchedRoute.match.path, with: "")
        if relativePath.hasPrefix("/more/") {
            relativePath = String(relativePath.dropFirst("/more".count))
        }
        
        self.tabPath = relativePath
        
    }
    
    public func getPath(incudeMore: Bool) -> String {
        
        let absolutePath: String = {
            if incudeMore {
                return "\(self.parentMatchedRoute.match.path)/more\(self.tabPath)"
            }
            else {
                return self.parentMatchedRoute.match.path + self.tabPath
            }
        }()
        
        return absolutePath
    }
    
}
