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
    
    private var tabNavigationControllers: [String: RSTabBarNavigationViewController]!
    
    //nil denotes that more is selected
    public var selectedTab: RSTab? {
        didSet {
            if let tab: RSTab = self.selectedTab {
                let nav: RSTabBarNavigationViewController = self.tabNavigationControllers[tab.identifier]!
                self.selectedViewController = nav
            }
            else {
                self.selectedViewController = self.moreNavigationController
            }
            
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
    
    var moreNavControllerDelegate: RSMoreNavigationControllerDelegate!
    
    var hasAppeared: Bool = false
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.delegate = self
        self.moreNavControllerDelegate = RSMoreNavigationControllerDelegate(tabBarLayoutVC: self)
        self.moreNavigationController.delegate = self.moreNavControllerDelegate
        
        let routeManager = RSApplicationDelegate.appDelegate.routeManager
        let state: RSState = self.store!.state
        let matchedRoute = self.matchedRoute
        let parentLayout = self.parentLayoutViewController.layout
        let childRoutes = self.matchedRoute.layout.childRoutes(routeManager: routeManager!, state: state, matchedRoute: matchedRoute, parentLayout: parentLayout)

        self.tabNavigationControllers = {
            
            //the native ios "More" view controller does this tricky thing of detecting if the vc for a tab is a nav controller,
            //if so, it ignores that VC and uses it's own navigation controller. Unfortunately, that messes with our assumptions
            //therefore, we will wrap our nav controller in another view controller to prevent this
            
            //also, because the more view controller expects that the view controllers are instantiated before a tap,
            //we instantiate all the children with "default" matches. Note that this might not be the best approach and if this is an issue,
            //we can simply put a dummy VC in there that has a rendering screen, and as soon as it renders for the first time, change the route the the correct route
            
            var navControllerMap: [String: RSTabBarNavigationViewController] = [:]
            self.tabLayout.tabs.forEach({ (tab) in
                
                let initialPath = "\(self.matchedRoute.match.path)/\(tab.identifier)"
                let match: RSMatch = RSMatch(params: [:], isExact: false, path: initialPath)
                let route: RSRoute = childRoutes.first(where: { $0.identifier == tab.identifier })!
                let layout: RSLayout = RSStateSelectors.layout(state, for: tab.layoutIdentifier)!
                
                do {
                    let vc = try layout.instantiateViewController(parent: self, matchedRoute: RSMatchedRoute(match: match, route: route, layout: layout))

                    self.childLayoutVCs = self.childLayoutVCs + [vc]
                    
                    let navController = RSNavigationController(rootViewController: vc.viewController)
                    navController.view.backgroundColor =  #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    let tabBarNavController = RSTabBarNavigationViewController(identifier: tab.identifier, viewController: navController, parentMatchedRoute: self.matchedRoute)
                    tabBarNavController.view.backgroundColor =  #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    tabBarNavController.title = tab.tabBarTitle
                    tabBarNavController.tabBarItem = UITabBarItem(title: tab.tabBarTitle, image: nil, selectedImage: nil)
                    tabBarNavController.setPath(path: initialPath)
                    navControllerMap[tab.identifier] = tabBarNavController
                }
                catch {
                    assertionFailure()
                }
 
            })
            
            return navControllerMap
        }()
        
        //make sure tabs are sorted based on how the user has previoulsy configured them
        self.viewControllers = self.tabLayout.sortedTabs(state: state).compactMap { self.tabNavigationControllers[$0.identifier] }
        self.viewControllers?.forEach({ (viewController) in
            assert(viewController is RSTabBarNavigationViewController)
        })
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.isNavigationBarHidden = true
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.layoutDidAppear(initialAppearance: !self.hasAppeared)
        self.hasAppeared = true
    }
    
    
    //here, we can sense that the user pressed the "more" button and reroute
    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return false
    }
    
    
    //update tab order
    //we sort the tabs based on this order when the VC loads
    //we also use this to deterimine which tabs are visible for routing purposes (ie.., do we add "/more")
    open func tabBarController(_ tabBarController: UITabBarController, willEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        
        if let tabOrderKey = self.tabLayout.tabOrderKey,
            changed {
            
            let tabOrder: [String] = viewControllers.compactMap { (viewController) -> String? in
                
                guard let nav = viewController as? RSTabBarNavigationViewController else {
                    return nil
                }
                return nav.identifier
                
            }
            
            debugPrint(tabOrder)
            self.store?.dispatch(RSActionCreators.setValueInState(key: tabOrderKey, value: tabOrder as NSArray))
            
        }
        
    }
    
    open func redirectToMorePath() {
        let morePath = "\(self.matchedRoute.match.path)/more"
        let pathChangeAction = RSActionCreators.requestPathChange(path: morePath)
        self.store?.dispatch(pathChangeAction)
    }
    
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        
        //note that if the item title is nil,
        //assume that this is the "More" route
        if item.title == nil {
            
            //reroute to more
            self.redirectToMorePath()
            
            return
            
        }
        
        
        //get tab for tab bar item
        let layout: RSTabBarLayout = self.layout as! RSTabBarLayout
        guard let tab = layout.tabs.first(where: { $0.tabBarTitle == item.title }),
            let nav = self.tabNavigationControllers[tab.identifier] else {

                return
        }
        
        //build path based on what's saved in the tab nav controller
        let absolutePath = nav.getPath(incudeMore: false)
        let action = RSActionCreators.requestPathChange(path: absolutePath)
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
    private var moreLayoutVC: RSMoreLayoutViewController?
    
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
        
        if let moreLayout = head.layout as? RSMoreLayout {
            
            let moreLayoutVC: RSMoreLayoutViewController! = {
                if let vc = self.moreLayoutVC {
                    self.moreLayoutVC?.layoutDidAppear(initialAppearance: false)
                    return vc
                }
                else {
                    do {
                        let vc = try moreLayout.instantiateViewController(parent: self, matchedRoute: head) as! RSMoreLayoutViewController
                        self.moreLayoutVC = vc
                        self.moreLayoutVC?.layoutDidLoad()
                        self.moreLayoutVC?.layoutDidAppear(initialAppearance: true)
                        return vc
                    }
                    catch let error {
                        completion?(nil, error)
                        return nil
                    }
                }
            }()
            
            moreLayoutVC.present(matchedRoutes: tail, animated: false, state: state) { (layoutVC, error) in
                
                //setting the selected tab to nil will set the "More" VC to the selected view controller
                self.selectedTab = nil
                completion?(layoutVC, error)
                
            }

            return
        }
        
        guard let tab = self.tabLayout.tabs.first(where: ({ $0.identifier == head.route.identifier })),
            let nav = self.tabNavigationControllers[tab.identifier] else {
                completion?(nil, nil)
                return
        }
        
        let animated = self.selectedViewController == nav && self.childLayoutVCs.count > 0
        
        //if the child exists, set the nav controller for this tab to the selected
        if let childVC = self.childLayoutVC(for: head) {
            childVC.updateLayout(matchedRoute: head, state: state)
            
            //update the stored path in the nav controller
            nav.setPath(path: last.match.path)
            self.selectedTab = tab
            childVC.present(matchedRoutes: tail, animated: animated, state: state, completion: completion)
            return
        }
        else {
            
            do {
                let childVC = try head.layout.instantiateViewController(parent: self, matchedRoute: head)
                childVC.viewController.title = tab.tabBarTitle
                self.childLayoutVCs = self.childLayoutVCs + [childVC]
                let rootNav = nav.rootViewController as! RSNavigationController
                rootNav.viewControllers = [childVC.viewController]
                //update the stored path in the nav controller
                nav.setPath(path: last.match.path)
                self.selectedTab = tab
                childVC.present(matchedRoutes: tail, animated: animated, state: state, completion: completion)
            }
            catch let error {
                completion?(nil, error)
            }
            
        }
        
    }
    
    public func updateLayout(matchedRoute: RSMatchedRoute, state: RSState) {
        
    }
    
    open func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            if let store = self.store {
                store.processAction(action: action, context: ["layoutViewController":self], store: store)
            }
        })
        
    }
    
    open func layoutDidAppear(initialAppearance: Bool) {
        
        if initialAppearance {
            self.layout.onFirstAppearanceActions.forEach({ (action) in
                if let store = self.store {
                    store.processAction(action: action, context: ["layoutViewController":self], store: store)
                }
            })
        }
        
    }
    
    public func backTapped() {
        
    }
    
}
