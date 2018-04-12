//
//  RSLayoutTitleViewController.swift
//  Pods
//
//  Created by James Kizer on 7/6/17.
//
//

import UIKit
import ReSwift
import Gloss
import ResearchSuiteExtensions

open class RSLayoutTitleViewController: UIViewController, StoreSubscriber, RSLayoutViewController {

    public var identifier: String! {
        return self.matchedRoute.route.identifier
    }
    
    public var matchedRoute: RSMatchedRoute!
    
    public var viewController: UIViewController! {
        return self
    }
    
    public var parentLayoutViewController: RSLayoutViewController!
    
    weak var store: Store<RSState>? {
        return RSApplicationDelegate.appDelegate.store
    }
    var titleLayout: RSTitleLayout! {
        return self.layout as! RSTitleLayout
    }
    open var layout: RSLayout! {
        return self.matchedRoute.layout
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: RSBorderedButton!
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.titleLabel.text = self.titleLayout.title
        self.imageView.image = self.titleLayout.image
        if let button = self.titleLayout.button {
            self.button.isHidden = false
            self.button.setTitle(button.title, for: .normal)
        }
        else {
            self.button.isHidden = true
        }
        
        self.navigationItem.title = self.layout.navTitle
        if let rightButton = self.layout.navButtonRight {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightButton.title, style: .plain, target: self, action: #selector(tappedRightBarButton))
        }
        
        self.store?.subscribe(self)
        
    }
    
    deinit {
        self.store!.unsubscribe(self)
    }
    
    open func newState(state: RSState) {
        
        guard let button = self.titleLayout.button else {
            return
        }
        
        self.button.isEnabled = {
            
            guard let predicate = button.predicate else {
                return true
            }
            
            return RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
            
        }()
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
    
    @IBAction func tappedButton(_ sender: Any) {
        
        guard let button = self.titleLayout.button else {
            return
        }
        
        button.onTapActions.forEach { self.processAction(action: $0) }
        
    }
    
    open func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            if let store = self.store {
                RSActionManager.processAction(action: action, context: ["layoutViewController":self], store: store)
            }
        })
        
    }
    
    
    private var childLayoutVCs: [RSLayoutViewController] = []
    
    private func childLayoutVC(for matchedRoute: RSMatchedRoute) -> RSLayoutViewController? {
        
        return childLayoutVCs.first(where: { (lvc) -> Bool in
            return lvc.matchedRoute.route.identifier == matchedRoute.route.identifier
        })
        
    }
    
    private func dismissChildLayout(childVC: RSLayoutViewController, animated: Bool, completion: ((Error?) -> Void)?) {
        guard let nav = self.navigationController as? RSNavigationController else {
            assertionFailure("unable to get nav controller")
            completion?(nil)
            return
        }
        
        nav.popViewController(layoutVC: childVC, animated: animated) { (viewController) in
            self.childLayoutVCs = self.childLayoutVCs.filter { $0.identifier != childVC.identifier }
            completion?(nil)
        }
    }
    
    public func present(matchedRoutes: [RSMatchedRoute], animated: Bool, state: RSState, completion: ((RSLayoutViewController?, Error?) -> Void)?) {
        
        //this type of viewController should have 0 or 1 children
        assert(self.childLayoutVCs.count < 2, "This view controller should have 0 or 1 children")
        
        if let head = matchedRoutes.first {
            let tail = Array(matchedRoutes.dropFirst())
            
            
            //if this child vc already exists, update it and continue
            if let lvc = childLayoutVC(for: head) {
                lvc.updateLayout(matchedRoute: head, state: state)
                lvc.present(matchedRoutes: tail, animated: animated, state: state, completion: completion)
                return
            }
            else {
                
                let presentAnimated = tail.count == 0 && animated
                //if this vc does not yet exist, we will need to instantiate it
                //however, since this VC is just part of a linear stream of VCs in nav controller, first
                //see if there is an existing child VC. if there is, dismiss it
                
                //this type of viewController should have 0 or 1 children
                assert(self.childLayoutVCs.count < 2, "This view controller should have 0 or 1 children")
                if let existingChild = self.childLayoutVCs.first {
                    self.dismissChildLayout(childVC: existingChild, animated: animated) { (error) in
                        if error != nil {
                            completion?(nil, error)
                        }
                        else {
                            self.presentChildLayout(matchedRoute: head, animated: presentAnimated, state: state) { (lvc, error) in
                                if error != nil {
                                    completion?(nil, error)
                                }
                                else {
                                    assert(lvc != nil)
                                    lvc!.present(matchedRoutes: tail, animated: animated, state: state, completion: completion)
                                }
                            }
                        }
                    }
                }
                else {
                    
                    self.presentChildLayout(matchedRoute: head, animated: presentAnimated, state: state) { (lvc, error) in
                        if error != nil {
                            completion?(nil, error)
                        }
                        else {
                            assert(lvc != nil)
                            lvc!.present(matchedRoutes: tail, animated: animated, state: state, completion: completion)
                        }
                    }
                }
            }
        }
        else {
            
            assert(self.childLayoutVCs.count < 2, "This view controller should have 0 or 1 children")
            if let existingChild = self.childLayoutVCs.first {
                self.dismissChildLayout(childVC: existingChild, animated: animated) { (error) in
                    if error != nil {
                        completion?(nil, error)
                    }
                    else {
                        completion?(self, nil)
                    }
                }
            }
            else {
                completion?(self, nil)
            }
            
        }
        
    }
    
    private func presentChildLayout(matchedRoute: RSMatchedRoute, animated: Bool, state: RSState, completion: ((RSLayoutViewController?, Error?) -> Void)?) {
        
        //check to see if child exists
        if let childVC = self.childLayoutVC(for: matchedRoute) {
            assertionFailure("Do we ever get here?? If not, we should probably remove this")
            childVC.updateLayout(matchedRoute: matchedRoute, state: state)
            completion?(childVC, nil)
        }
        else {
            guard let nav = self.navigationController as? RSNavigationController else {
                assertionFailure("unable to get nav controller")
                completion?(nil, nil)
                return
            }
            
            do {
                
                let layoutVC = try matchedRoute.layout.instantiateViewController(parent: self, matchedRoute: matchedRoute)
                self.childLayoutVCs = self.childLayoutVCs + [layoutVC]
                nav.pushViewController(layoutVC.viewController, animated: animated) {
                    completion?(layoutVC, nil)
                }
            }
            catch let error {
                completion?(nil, error)
            }
        }
        
    }
    
    public func updateLayout(matchedRoute: RSMatchedRoute, state: RSState) {
        
    }

}
