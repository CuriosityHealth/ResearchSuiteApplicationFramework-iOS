//
//  RSTabBarNavigationViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/15/18.
//

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
        debugPrint(relativePath)
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
        
        debugPrint(absolutePath)
        return absolutePath
    }
    
}
