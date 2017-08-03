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
    func setContentHidden(contentHidden: Bool)
}

open class RSRoutingNavigationController: UINavigationController, StoreSubscriber, RSRouterDelegate {
    
    var store: Store<RSState>!
    var layoutManager: RSLayoutManager!
    var activityManager: RSActivityManager!

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.store.subscribe(self)
    }
    
    deinit {
        self.store.unsubscribe(self)
    }
    
    open func setContentHidden(contentHidden: Bool) {
        if let vc = self.presentedViewController {
            vc.view.isHidden = contentHidden
        }
        
        self.view.isHidden = contentHidden
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
        
        //only route if the passcode view controller is NOT presented
        if RSApplicationDelegate.appDelegate.isPasscodePresented() {
            return
        }
        
        //first, lets check to see if there is a new layout to route
        let routes = RSStateSelectors.routes(state)
        let firstRouteOpt = routes.first { (route) -> Bool in
            
            guard let predicate = route.predicate else {
                return true
            }
            
            return RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
            
        }
        
        if let firstRoute = firstRouteOpt,
            RSStateSelectors.shouldRoute(state, route: firstRoute) {
            self.store.dispatch(RSActionCreators.setRoute(route: firstRoute, layoutManager: self.layoutManager, delegate: self))
        }
            //otherwise, check to see if there is an activity to present
        else if RSStateSelectors.shouldPresent(state) {
            self.store.dispatch(RSActionCreators.presentActivity(on: self, activityManager: self.activityManager))
        }
        
        
        
    }
    
    open func generateLayout(for route: RSRoute, state: RSState) -> UIViewController? {
        
        guard let layout = RSStateSelectors.layout(state, for: route.layout) else {
            return nil
        }
        return self.layoutManager.generateLayout(layout: layout, store: self.store)
    }

}
