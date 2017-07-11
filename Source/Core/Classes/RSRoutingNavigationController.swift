//
//  RSRoutingNavigationController.swift
//  Pods
//
//  Created by James Kizer on 7/11/17.
//
//

import UIKit
import ReSwift

public protocol RSRouterDelegate: class {
    func presentLayout(viewController: UIViewController, completion: ((Bool) -> Swift.Void)?)
}

open class RSRoutingNavigationController: UINavigationController, StoreSubscriber, RSRouterDelegate {
    
    var store: Store<RSState>!
    var layoutManager: RSLayoutManager!

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.store.subscribe(self)
    }
    
    deinit {
        self.store.unsubscribe(self)
    }
    

    open func presentLayout(viewController: UIViewController, completion: ((Bool) -> Swift.Void)?) {
        self.transition(toRootViewController: viewController, animated: true, completion: { presented in
            completion?(presented)
        })
    }
    
    //there is a bug when we are presenting a modal view controller and we reset the rootViewController
    //note that when we move to the logic being owned by the state, we can account for this
    //i.e., check to see if something is presented before we re-route
    //also, check to see if we are rerouting before we present
    open func transition(toRootViewController: UIViewController, animated: Bool, completion: ((Bool) -> Swift.Void)? = nil) {
        if (animated) {
            
            let snapshot:UIView = (self.topViewController?.view.snapshotView(afterScreenUpdates: true))!
            
            
            //this causes viewdidLoad for toRootViewController to be called
            //if this is a layout view controller, its actions will be executed
//            toRootViewController.view.addSubview(snapshot);
            
            self.viewControllers = [toRootViewController]
            toRootViewController.view.addSubview(snapshot)
            
            UIView.animate(withDuration: 0.3, animations: {() in
                snapshot.layer.opacity = 0;
            }, completion: {
                (value: Bool) in
                snapshot.removeFromSuperview()
                completion?(value)
            })
        }
        else {
            self.viewControllers = [toRootViewController]
            completion?(true)
        }
        
    }
    
    open func newState(state: RSState) {
        
        let routes = RSStateSelectors.routes(state)
        
        let firstRouteOpt = routes.first { (route) -> Bool in
            
            guard let predicate = route.predicate else {
                return true
            }
            
            return RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
            
        }
        
        guard let firstRoute = firstRouteOpt,
            !RSStateSelectors.isRouting(state) else {
            return
        }
        
        self.store.dispatch(RSActionCreators.setRoute(route: firstRoute, layoutManager: self.layoutManager, delegate: self))
        
    }
    
    open func generateLayout(for route: RSRoute, state: RSState) -> UIViewController? {
        
        guard let layout = RSStateSelectors.layout(state, for: route.layout) else {
            return nil
        }
        return self.layoutManager.generateLayout(layout: layout, store: self.store)
    }

}
