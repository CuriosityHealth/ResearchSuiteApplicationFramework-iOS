//
//  RSRouter.swift
//  Pods
//
//  Created by James Kizer on 7/3/17.
//
//

import UIKit
import ReSwift

public protocol RSRouterDelegate: class {
    func presentLayout(viewController: UIViewController, completion: ((Bool) -> Swift.Void)?)
}

open class RSRouter: NSObject, StoreSubscriber {
    
    var currentRoute: RSRoute? = nil
    let layoutManager: RSLayoutManager
    weak var delegate: RSRouterDelegate?
    let store: Store<RSState>
    
    public init(
        store: Store<RSState>,
        layoutManager: RSLayoutManager,
        delegate: RSRouterDelegate
        ) {
        
        self.store = store
        self.layoutManager = layoutManager
        self.delegate = delegate
        
        super.init()
    }
    
    open func newState(state: RSState) {
        
        let routes = RSStateSelectors.routes(state)
        
        let firstRouteOpt = routes.first { (route) -> Bool in
            
            guard let predicate = route.predicate else {
                return true
            }
            
            return RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
            
        }
        
        guard let firstRoute = firstRouteOpt else {
            return
        }
        
        if self.currentRoute == nil {
            self.currentRoute = firstRoute
            if let layoutVC = self.generateLayout(for: firstRoute, state: state) {
                self.delegate?.presentLayout(viewController: layoutVC, completion: {presented in
                    if presented {
                        guard let layout = RSStateSelectors.layout(state, for: firstRoute.layout) else {
                            return
                        }

                        layout.onLoadActions.forEach({ (action) in
                            RSActionManager.processAction(action: action, context: ["layoutViewController":layoutVC], store: self.store)
                        })
                    }
                })
            }
        }
        else if self.currentRoute!.identifier != firstRoute.identifier {
            self.currentRoute = firstRoute
            if let layoutVC = self.generateLayout(for: firstRoute, state: state) {
                self.delegate?.presentLayout(viewController: layoutVC, completion: {presented in
                    if presented {
                        guard let layout = RSStateSelectors.layout(state, for: firstRoute.layout) else {
                            return
                        }
                        
                        layout.onLoadActions.forEach({ (action) in
                            RSActionManager.processAction(action: action, context: ["layoutViewController":layoutVC], store: self.store)
                        })
                    }
                })
            }
        }
        
    }
    
    open func generateLayout(for route: RSRoute, state: RSState) -> UIViewController? {
        
        guard let layout = RSStateSelectors.layout(state, for: route.layout) else {
            return nil
        }
        return self.layoutManager.generateLayout(layout: layout, store: self.store)
    }
    
    

}
