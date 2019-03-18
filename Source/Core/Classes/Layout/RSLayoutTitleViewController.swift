//
//  RSLayoutTitleViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/6/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import Gloss
import ResearchSuiteExtensions

open class RSLayoutTitleViewController: UIViewController, StoreSubscriber, RSSingleLayoutViewController {

    public var identifier: String! {
        return self.matchedRoute.route.identifier
    }
    
    public let uuid: UUID = UUID()
    
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
    @IBOutlet weak var titleToImageViewSpace: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    var button: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    private var hasAppeared: Bool = false

    open func updateUI(state: RSState) {

        if let title = self.titleLayout.title {
            self.titleLabel?.text = RSApplicationDelegate.localizedString(title)
        }
        else if let titleJSON = self.titleLayout.titleJSON,
            let title = RSValueManager.processValue(jsonObject: titleJSON, state: state, context: self.context())?.evaluate() as? String {
            self.titleLabel?.text = RSApplicationDelegate.localizedString(title)
        }
        
        if let titleTextColorJSON = self.titleLayout.titleTextColorJSON,
            let titleTextColor = RSValueManager.processValue(jsonObject: titleTextColorJSON, state: state, context: self.context())?.evaluate() as? UIColor {
            
            self.titleLabel.textColor = titleTextColor
        }
        
        if let titleFontJSON = self.titleLayout.titleFontJSON,
            let titleFont = RSValueManager.processValue(jsonObject: titleFontJSON, state: state, context: self.context())?.evaluate() as? UIFont {
            self.titleLabel.font = titleFont
//            self.titleLabel.adjustsFontForContentSizeCategory = false
        }
        
        self.backgroundImageView?.image = self.titleLayout.backgroundImage
        if let backgroundColorJSON = self.titleLayout.backgroundColorJSON,
            let backgroundColor = RSValueManager.processValue(jsonObject: backgroundColorJSON, state: state, context: self.context())?.evaluate() as? UIColor {
            
            self.backgroundImageView.backgroundColor = backgroundColor
        }
        
        if let titleToImageViewSpace = self.titleLayout.titleToImageViewSpace {
            self.titleToImageViewSpace.constant = titleToImageViewSpace
        }
        
        //create button only once
        //update button
        self.button?.removeFromSuperview()
        self.button = nil
        
        if let button = self.titleLayout.button {
            
            let newButton: UIButton = {
                switch button.buttonType {
                case .bordered:
                    
                    let newButton = RSBorderedButton(type: .custom)
                    
                    if let primaryColorJSON = button.primaryColorJSON,
                        let primaryColor = RSValueManager.processValue(jsonObject: primaryColorJSON, state: state, context: self.context())?.evaluate() as? UIColor {
                        
                        if let secondaryColorJSON = button.secondaryColorJSON,
                            let secondaryColor = RSValueManager.processValue(jsonObject: secondaryColorJSON, state: state, context: self.context())?.evaluate() as? UIColor {
                            
                            newButton.setColors(primaryColor: primaryColor, secondaryColor: secondaryColor)
                        }
                        else {
                            newButton.setColors(primaryColor: primaryColor)
                        }
                    }

                    return newButton
                case .solid:
                    let newButton = RSSolidButton(type: .custom)
                    
                    if let primaryColorJSON = button.primaryColorJSON,
                        let primaryColor = RSValueManager.processValue(jsonObject: primaryColorJSON, state: state, context: self.context())?.evaluate() as? UIColor {
                        
                        if let secondaryColorJSON = button.secondaryColorJSON,
                            let secondaryColor = RSValueManager.processValue(jsonObject: secondaryColorJSON, state: state, context: self.context())?.evaluate() as? UIColor {
                            
                            newButton.setColors(titleColor: primaryColor, backgroundColor: secondaryColor)
                        }
                        else {
                            newButton.setColors(titleColor: primaryColor, backgroundColor: nil)
                        }
                    }
                    
                    return newButton
                }
            }()
            
            self.view.addSubview(newButton)
            
            newButton.snp.makeConstraints { (make) in
                make.height.equalTo(44)
                make.width.greaterThanOrEqualTo(150)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-40)
            }
            
            newButton.isHidden = false
            newButton.setTitle(RSApplicationDelegate.localizedString(button.title), for: .normal)
            newButton.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
            
            self.button = newButton
            
        }
        else {
            self.button?.isHidden = true
        }
        
        self.imageView?.image = self.titleLayout.image

        self.navigationItem.title = self.localizationHelper.localizedString(self.layout.navTitle)
        
        let onTap: (RSBarButtonItem) -> () = { [unowned self] button in
            button.layoutButton.onTapActions.forEach { self.processAction(action: $0) }
        }
        
        self.navigationItem.rightBarButtonItems = self.layout.rightNavButtons?.compactMap { (layoutButton) -> UIBarButtonItem? in
            return RSBarButtonItem(layoutButton: layoutButton, onTap: onTap, localizationHelper: self.localizationHelper)
        }
        
    }
    
    open func reloadLayout() {
        if let state = self.store?.state {
            self.updateUI(state: state)
        }
        
        self.childLayoutVCs.forEach({ $0.reloadLayout() })
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = self.layout.hidesNavBar
        

        // Do any additional setup after loading the view.
        if let state = self.store?.state {
            self.updateUI(state: state)
        }

        self.store?.subscribe(self)
        
        self.layoutDidLoad()
        
    }
    
    deinit {
        self.store?.unsubscribe(self)
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
            
            return RSPredicateManager.evaluatePredicate(predicate: predicate, state: state, context: self.context())
            
        }()
    }
    
    open func processAction(action: JSON) {
        if let store = self.store {
            store.processAction(action: action, context: self.context(), store: store)
        }
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
        self.matchedRoute = matchedRoute
        self.updateUI(state: state)
    }
    
    public func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            if let store = self.store {
                store.processAction(action: action, context: self.context(), store: store)
            }
        })
        
    }
    
    public func layoutDidAppear(initialAppearance: Bool) {
        
        if initialAppearance {
            self.layout.onFirstAppearanceActions.forEach({ (action) in
                if let store = self.store {
                    store.processAction(action: action, context: self.context(), store: store)
                }
            })
        }
        
    }

}
