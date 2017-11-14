//
//  RSLayoutTabBarViewController.swift
//  Pods
//
//  Created by James Kizer on 7/3/17.
//
//

import UIKit
import ReSwift
import Gloss

open class RSLayoutTabBarViewController: UITabBarController, StoreSubscriber, RSLayoutViewControllerProtocol, UITabBarControllerDelegate {
    
    
    //note that viewDidLoad for RSLayoutTabBarViewController was getting invoked prior to returning
    //from instantiation. We moved the subscribe call method to the store set listener
    //We use layout and layoutManager in the newState method
    //therefore, layout and layoutManager MUST be set prior to setting store
    weak var store: Store<RSState>? {
        didSet {
            store?.subscribe(self)
        }
    }
    var state: RSState!
    public var layout: RSLayout! {
        return self.tabLayout
    }
    
    var tabLayout: RSTabLayout!
    var layoutManager: RSLayoutManager!
    
    var visibleLayoutItems: [RSTabItem] = []
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        self.navigationItem.title = self.layout.navTitle
        if let rightButton = self.layout.navButtonRight {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightButton.title, style: .plain, target: self, action: #selector(tappedRightBarButton))
        }
    }
    
    deinit {
        self.store?.unsubscribe(self)
    }

    open func processAction(action: JSON) {
        if let store = self.store {
            RSActionManager.processAction(action: action, context: ["layoutViewController":self], store: store)
        }
    }
    
    @objc
    func tappedRightBarButton() {
        guard let button = self.layout.navButtonRight else {
            return
        }
        
        button.onTapActions.forEach { self.processAction(action: $0) }
    }
    
    open func backTapped() {
        self.layout.onBackActions.forEach { self.processAction(action: $0) }
    }
    
    open func computeVisibleLayoutItems() -> [String] {
        return self.tabLayout.items.filter { self.shouldShowItem(item: $0) }.map { $0.identifier }
    }
    
    open func shouldShowItem(item: RSTabItem) -> Bool {
        guard let predicate = item.predicate else {
            return true
        }
        
        return RSActivityManager.evaluatePredicate(predicate: predicate, state: self.state, context: [:])
    }
    
    //listen to changes
    //evaluate predictates
    //if any changes, reload child vcs and set them
    //use setViewControllers
    open func newState(state: RSState) {
        
        self.state = state
        
        //we should only reload tabs if values bound by list item predicates have changed
        //but this is probably a premature optimization
        let newVisibleLayoutItems = self.computeVisibleLayoutItems()
        let currentVisibleLayoutItems = self.visibleLayoutItems.map { $0.identifier }
        if newVisibleLayoutItems != currentVisibleLayoutItems {
            self.visibleLayoutItems = newVisibleLayoutItems.flatMap { self.tabLayout.itemMap[$0] }
            //we're returning pairs here because we'd like to execute actions after the VCs have been loaded
            let vcs: [UIViewController] = self.visibleLayoutItems.flatMap({ (tabItem) -> UIViewController? in
                
                guard let layout = RSStateSelectors.layout(state, for: tabItem.identifier),
                    let store = self.store,
                    let vc = self.layoutManager.generateLayout(layout: layout, store: store) else {
                        return nil
                }
                
                let image: UIImage? = (tabItem.imageTitle != nil) ? UIImage(named: tabItem.imageTitle!) : nil
                let selectedImage: UIImage? = (tabItem.selectedImageTitle != nil) ? UIImage(named: tabItem.selectedImageTitle!) : nil
                
                vc.tabBarItem = UITabBarItem(title: tabItem.shortTitle, image: image, selectedImage: selectedImage)
                
                return vc
                
            })
            
            //first set view controllers
            self.setViewControllers(vcs, animated: true)
            
            //if this is not the first load, emit onLoad actions for each new VCs
            //these will get handled by layoutDidLoad
            if currentVisibleLayoutItems.count > 0 {
                //then execute actions for newly shown visible items
                let pairs: [(UIViewController, RSLayout)] = vcs.flatMap { layoutVC in
                    guard let lvc = layoutVC as? RSLayoutViewControllerProtocol else {
                        return nil
                    }
                    return (layoutVC, lvc.layout)
                }
                
                pairs
                    .filter { !currentVisibleLayoutItems.contains($0.1.identifier) }
                    .forEach { pair in
                        pair.1.onLoadActions.forEach({ (action) in
                            debugPrint(action)
                            if let store = self.store {
                                RSActionManager.processAction(action: action, context: ["layoutViewController":pair.0], store: store)
                            }
                        })
                        
                }
            }
            
        }
        
    }
    
    open func generateLayout(for layoutIdentifier: String, state: RSState) -> UIViewController? {
        
        guard let layout = RSStateSelectors.layout(state, for: layoutIdentifier),
            let store = self.store else {
            return nil
        }
        return self.layoutManager.generateLayout(layout: layout, store: store)
    }
    
    open func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            if let store = self.store {
                RSActionManager.processAction(action: action, context: ["layoutViewController":self], store: store)
            }
        })
        
        guard let vcs = self.viewControllers?.flatMap({ (vc) -> RSLayoutViewControllerProtocol? in
            return vc as? RSLayoutViewControllerProtocol
        }) else {
            return
        }
        
        vcs.forEach { $0.layoutDidLoad() }
        
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let layoutVC = viewController as? RSLayoutViewControllerProtocol,
            let layout = layoutVC.layout else {
            return
        }
        
        guard let tabItem = self.visibleLayoutItems.first(where: { (tabItem) -> Bool in
            return layout.identifier == tabItem.identifier
        }) else {
            return
        }
        
        tabItem.onTapActions.forEach({ (action) in
            if let store = self.store {
                RSActionManager.processAction(action: action, context: ["layoutViewController":self], store: store)
            }
        })
    }

}
