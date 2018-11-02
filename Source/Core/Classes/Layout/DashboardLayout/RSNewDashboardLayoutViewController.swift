//
//  RSNewDashboardLayoutViewController.swift
//  Pods
//
//  Created by James Kizer on 9/16/18.
//

import UIKit
import ReSwift
import Gloss
import LS2SDK
import ResearchSuiteExtensions

open class RSNewDashboardLayoutViewController: UIViewController, UICollectionViewDelegateFlowLayout, StoreSubscriber, RSSingleLayoutViewController {
    
    
    static let TAG = "RSDashboardLayoutViewController"
    
    public var identifier: String! {
        return self.matchedRoute.route.identifier
    }
    
    public var matchedRoute: RSMatchedRoute!
    
    public var viewController: UIViewController! {
        return self
    }
    
    public var parentLayoutViewController: RSLayoutViewController!
    
    var state: RSState?
    var lastState: RSState?
    weak var store: Store<RSState>? {
        return RSApplicationDelegate.appDelegate.store
    }
    
    var dashboardLayout: RSNewDashboardLayout! {
        return self.layout as! RSNewDashboardLayout
    }
    
    open var layout: RSLayout! {
        return self.matchedRoute.layout
    }
    
    var hasAppeared: Bool = false
    
    var collectionViewCellManager: RSCollectionViewCellManager!
    var logger: RSLogger?
    
    //this is intended to hold adaptor strongly
    //this allows us to generate adaptors on the fly
    var adaptor: RSDashboardAdaptor?
    
    @IBOutlet weak var collectionView: UICollectionView!

    
    open func initializeNavBar() {
        
        self.navigationItem.title = self.localizationHelper.localizedString(self.layout.navTitle)
        if let rightButtons = self.layout.rightNavButtons {
            let onTap: (RSBarButtonItem) -> () = { [unowned self] button in
                button.layoutButton.onTapActions.forEach { self.processAction(action: $0) }
            }
            
            let rightBarButtons = rightButtons.compactMap { (layoutButton) -> UIBarButtonItem? in
                return RSBarButtonItem(layoutButton: layoutButton, onTap: onTap, localizationHelper: self.localizationHelper)
            }
            
            self.navigationItem.rightBarButtonItems = rightBarButtons
        }
        
    }
    
    open func reloadLayout() {
        
        //        self.initializeNavBar()
        //        self.collectionView?.reloadData()
        //        self.childLayoutVCs.forEach({$0.reloadLayout()})
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeNavBar()
        
        self.store?.subscribe(self)
        self.state = self.store?.state

        guard let state = self.store?.state else {
            return
        }
        
        if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout,
            let window = UIApplication.shared.windows.first {
            let cellWidth = window.frame.size.width - (flowLayout.sectionInset.right + flowLayout.sectionInset.left)
            flowLayout.estimatedItemSize = CGSize(width: cellWidth, height: cellWidth)
        }
        
        if let backgroundImage = self.dashboardLayout.backgroundImage {
            let imageView = UIImageView(image: backgroundImage)
            imageView.contentMode = .bottom
            self.collectionView!.backgroundView = imageView
        }
        
        if let backgroundColorJSON = self.dashboardLayout.backgroundColorJSON,
            let backgroundColor = RSValueManager.processValue(jsonObject: backgroundColorJSON, state: state, context: self.context())?.evaluate() as? UIColor {
            
            self.collectionView!.backgroundColor = backgroundColor
        }
        else {
            self.collectionView!.backgroundColor = UIColor.groupTableViewBackground
        }
        
        if let adaptor = RSStateSelectors.getValueInCombinedState(state, for: self.dashboardLayout.adaptor) as? RSDashboardAdaptor {
            
            //hold this strongly
            self.adaptor = adaptor
            self.collectionView.dataSource = adaptor
            self.collectionView.delegate = adaptor
            adaptor.configure(collectionView: self.collectionView)
            
            
            
        }
        
    }
    
    
    
    
    
    open func newState(state: RSState) {
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if self.visibleItems == nil {
//            self.updateVisibleItems()
//        }
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.layoutDidAppear(initialAppearance: !self.hasAppeared)
        self.hasAppeared = true
    }
    
    open func backTapped() {
        self.layout.onBackActions.forEach { self.processAction(action: $0) }
    }
    
    open func processAction(action: JSON, extraContext: [String : AnyObject]? = nil) {
        if let store = self.store {
            store.processAction(action: action, context: self.context(extraContext: extraContext), store: store)
        }
    }
    
    open func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            self.processAction(action: action)
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
    
    public var childLayoutVCs: [RSLayoutViewController] = []
    
    public func childLayoutVC(for matchedRoute: RSMatchedRoute) -> RSLayoutViewController? {
        
        return childLayoutVCs.first(where: { (lvc) -> Bool in
            return lvc.matchedRoute.route.identifier == matchedRoute.route.identifier
        })
        
    }
    
    public func updateLayout(matchedRoute: RSMatchedRoute, state: RSState) {
        self.matchedRoute = matchedRoute
    }
    
    
    

}
