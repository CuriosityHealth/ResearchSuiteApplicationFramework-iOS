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

open class RSLayoutTitleViewController: UIViewController, StoreSubscriber, RSSingleLayoutViewController {

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
    
    private var hasAppeared: Bool = false
    override open func viewDidLoad() {
        super.viewDidLoad()

        debugPrint(self.layout.identifier)
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
        
        self.layoutDidLoad()
        
    }
    
    deinit {
        self.store!.unsubscribe(self)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.layoutDidAppear(initialAppearance: !self.hasAppeared)
        self.hasAppeared = true
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
    
    public var childLayoutVCs: [RSLayoutViewController] = []
    
    public func childLayoutVC(for matchedRoute: RSMatchedRoute) -> RSLayoutViewController? {
        
        return childLayoutVCs.first(where: { (lvc) -> Bool in
            return lvc.matchedRoute.route.identifier == matchedRoute.route.identifier
        })
        
    }
    
    public func updateLayout(matchedRoute: RSMatchedRoute, state: RSState) {
        
    }
    
    public func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            if let store = self.store {
                RSActionManager.processAction(action: action, context: ["layoutViewController":self], store: store)
            }
        })
        
    }
    
    public func layoutDidAppear(initialAppearance: Bool) {
        
        if initialAppearance {
            self.layout.onFirstAppearanceActions.forEach({ (action) in
                if let store = self.store {
                    RSActionManager.processAction(action: action, context: ["layoutViewController":self], store: store)
                }
            })
        }
        
    }

}
