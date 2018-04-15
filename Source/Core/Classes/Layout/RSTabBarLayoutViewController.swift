//
//  RSTabBarLayoutViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/15/18.
//

import UIKit
import ReSwift
import Gloss

open class RSTabBarLayoutViewController: UITabBarController, UITabBarControllerDelegate, RSLayoutViewController {

    var state: RSState?
    var lastState: RSState?
    weak var store: Store<RSState>? {
        return RSApplicationDelegate.appDelegate.store
    }
    
    private var tabNavigationControllers: [String: RSNavigationController]!
    private var tabPaths: [String: String]!
    
    public var selectedTab: RSTab! {
        didSet {
            let tab: RSTab = self.selectedTab
            let nav: RSNavigationController = self.tabNavigationControllers[tab.identifier]!
            self.selectedViewController = nav
        }
    }
    
    public init(identifier: String, matchedRoute: RSMatchedRoute, parent: RSLayoutViewController) {
        self.matchedRoute = matchedRoute
        self.parentLayoutViewController = parent
        super.init(nibName: nil, bundle: nil)
        self.identifier = identifier
        
    }
    
    var tabLayout: RSTabBarLayout! {
        return self.layout as! RSTabBarLayout
    }
    open var layout: RSLayout! {
        return self.matchedRoute.layout
    }
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.delegate = self
        
        self.tabPaths = {
            var tabPathMap: [String: String] = [:]
            self.tabLayout.tabs.forEach({ (tab) in
                let initialPath = "\(self.matchedRoute.match.path)/\(tab.identifier)"
                tabPathMap[tab.identifier] = initialPath
            })
            return tabPathMap
        }()
        
        self.tabNavigationControllers = {
            
            var navControllerMap: [String: RSNavigationController] = [:]
            self.tabLayout.tabs.forEach({ (tab) in
                
                let navController = RSNavigationController()
                navController.view.backgroundColor =  #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                navController.title = tab.tabBarTitle
                navController.tabBarItem = UITabBarItem(title: tab.tabBarTitle, image: nil, selectedImage: nil)
                navControllerMap[tab.identifier] = navController
                
            })
            
            return navControllerMap
        }()
        
        self.viewControllers = self.tabLayout.tabs.compactMap { self.tabNavigationControllers[$0.identifier] }
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.isNavigationBarHidden = true
    }
    
    
    //here, we can sense that the user pressed the "more" button and reroute
    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return !(viewController is RSNavigationController)
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, willEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        
        viewControllers.forEach { (vc) in
            
            
            debugPrint(vc)
            
        }
        
    }
    
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
//        self.selectedViewController = self.moreNavigationController
//        return
        
        //get tab for tab bar item
        let layout: RSTabBarLayout = self.layout as! RSTabBarLayout
        guard let tab = layout.tabs.first(where: { $0.tabBarTitle == item.title }),
            let path = self.tabPaths[tab.identifier] else {
                
                
                var swappedViewControllers = self.viewControllers!
                let firstVC = swappedViewControllers[0]
                swappedViewControllers[0] = swappedViewControllers[1]
                swappedViewControllers[1] = firstVC
                self.setViewControllers(swappedViewControllers, animated: true)
                
                return
        }
        
//        AppDelegate.shared.rootViewController.setCurrentPath(path: path)
        
        let action = RSActionCreators.requestPathChange(path: path)
        self.store?.dispatch(action)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var identifier: String!
    
    public var matchedRoute: RSMatchedRoute!
    
    public var viewController: UIViewController! {
        return self
    }
    
    public var parentLayoutViewController: RSLayoutViewController!
    
    private var childLayoutVCs: [RSLayoutViewController] = []
    
    private func childLayoutVC(for matchedRoute: RSMatchedRoute) -> RSLayoutViewController? {
        return childLayoutVCs.first(where: { (lvc) -> Bool in
            return lvc.matchedRoute.route.identifier == matchedRoute.route.identifier
        })
    }
    
    public func present(matchedRoutes: [RSMatchedRoute], animated: Bool, state: RSState, completion: ((RSLayoutViewController?, Error?) -> Void)?) {
        
//        debugPrint(matchedRoute)
        
        guard let head = matchedRoutes.first,
            let last = matchedRoutes.last else {
                assertionFailure("Cannot match a tab bar layout. Must match one of its children.")
                return
        }
        
        let tail = Array(matchedRoutes.dropFirst())
        
        guard let tab = self.tabLayout.tabs.first(where: ({ tab in
            
            return tab.identifier == head.route.identifier
//                if let identifier: String = "identifier" <~~ tab.identifier {
//                    return identifier == head.route.identifier
//                }
//                else {
//                    return false
//                }
             }) ),
            let nav = self.tabNavigationControllers[tab.identifier] else {
                completion?(nil, nil)
                return
        }
        
        let animated = self.selectedViewController == nav && self.childLayoutVCs.count > 0
        
        //if the child exists, set the nav controller for this tab to the selected
        if let childVC = self.childLayoutVC(for: head) {
            childVC.updateLayout(matchedRoute: head, state: state)
            self.tabPaths[tab.identifier] = last.match.path
            self.selectedTab = tab
            childVC.present(matchedRoutes: tail, animated: animated, state: state, completion: completion)
            return
        }
        else {
            
            do {
                let childVC = try head.layout.instantiateViewController(parent: self, matchedRoute: head)
                childVC.viewController.title = tab.tabBarTitle
                self.childLayoutVCs = self.childLayoutVCs + [childVC]
                nav.pushViewController(childVC.viewController, animated: false) {
                    //update the tab path and set the selected tab
                    self.tabPaths[tab.identifier] = last.match.path
                    self.selectedTab = tab
                    childVC.present(matchedRoutes: tail, animated: animated, state: state, completion: completion)
                }
            }
            catch let error {
                completion?(nil, error)
            }
            
        }
        
    }
    
    public func updateLayout(matchedRoute: RSMatchedRoute, state: RSState) {
        
    }
    
    public func layoutDidLoad() {
        
    }
    
    public func backTapped() {
        
    }
    
}
