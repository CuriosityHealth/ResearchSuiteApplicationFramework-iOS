//
//  RSLayoutTableViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/3/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ReSwift
import Gloss
import CoreLocation
import ResearchSuiteTaskBuilder

open class RSLayoutTableViewController: UITableViewController, StoreSubscriber, RSSingleLayoutViewController {

    public var identifier: String! {
        return self.matchedRoute.route.identifier
    }
    
    public let uuid: UUID = UUID()
    
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
    
    var listLayout: RSListLayout! {
        return self.layout as! RSListLayout
    }
    
    open var layout: RSLayout! {
        return self.matchedRoute.layout
    }
    
    var visibleLayoutItems: [RSListItem] = []
    var hasAppeared: Bool = false
    
    open func initializeNavBar() {
        
        self.navigationItem.title = self.localizationHelper.localizedString(self.layout.navTitle)
        
        let onTap: (RSBarButtonItem) -> () = { [unowned self] button in
            button.layoutButton.onTapActions.forEach { self.processAction(action: $0) }
        }
        
        self.navigationItem.rightBarButtonItems = self.layout.rightNavButtons?.compactMap { (layoutButton) -> UIBarButtonItem? in
            return RSBarButtonItem(layoutButton: layoutButton, onTap: onTap, localizationHelper: self.localizationHelper)
        }
        
    }
    
    open func reloadLayout() {
        
        self.initializeNavBar()
        self.tableView?.reloadData()
        self.childLayoutVCs.forEach({ $0.reloadLayout() })
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeNavBar()
        
        self.store?.subscribe(self)
        
        if let state = self.store?.state {
            self.visibleLayoutItems = self.listLayout.items.filter { self.shouldShowItem(item: $0, state: state) }
            self.state = state
        }

        self.refreshControl?.addTarget(self, action: #selector(RSLayoutTableViewController.handleRefresh(_:)), for: .valueChanged)
        
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
    
//    @objc
//    func tappedRightBarButton() {
//        guard let button = self.layout.navButtonRight else {
//            return
//        }
//
//        button.onTapActions.forEach { self.processAction(action: $0) }
//    }
    
    open func backTapped() {
        self.layout.onBackActions.forEach { self.processAction(action: $0) }
    }
    
    open func processAction(action: JSON) {
        if let store = self.store {
            store.processAction(action: action, context: ["layoutViewController":self], store: store)
        }
    }
    
    open func computeVisibleLayoutItems(state: RSState) -> [String] {
        return self.listLayout.items.filter { self.shouldShowItem(item: $0, state: state) }.map { $0.identifier }
    }
    
    open func newState(state: RSState) {
        
        guard let lastState = self.lastState else {
            self.lastState = state
            return
        }
        
        self.state = state
        self.loadData(state: state)
        
        let shouldReload = self.listLayout.monitoredValues.reduce(false) { (acc, monitoredValue) -> Bool in
            return acc || RSValueManager.valueChanged(jsonObject: monitoredValue, state: state, lastState: lastState, context: [:])
        }
        
        if shouldReload {
            self.tableView.reloadData()
        }
        
        self.lastState = state
        
        
        
    }
    
    @objc
    open func handleRefresh(_ refreshControl: UIRefreshControl) {
        if let state = self.state {
            self.loadData(state: state)
        }
        
        self.loadFinished()
    }
    
    func loadData(state: RSState) {
        
        
        //we should only reload cells if values bound by list item predicates have changed
        //but this is probably a premature optimization
        let newVisibleLayoutItems = self.computeVisibleLayoutItems(state: state)
        let currentVisibleLayoutItems = self.visibleLayoutItems.map { $0.identifier }
        if newVisibleLayoutItems != currentVisibleLayoutItems {
            self.visibleLayoutItems = newVisibleLayoutItems.compactMap { self.listLayout.itemMap[$0] }
            self.loadFinished()
            return
        }
        
        
        
        
    }
    
    func loadFinished() {
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
    open func shouldShowItem(item: RSListItem, state: RSState) -> Bool {
        guard let predicate = item.predicate else {
            return true
        }
        
        return RSPredicateManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
    }
    
    open func itemForIndexPath(indexPath: IndexPath) -> RSListItem? {
        return self.itemForRow(row: indexPath.row)
    }
    
    open func itemForRow(row: Int) -> RSListItem? {
        let index = row
        
        guard index >= self.visibleLayoutItems.startIndex,
            index < self.visibleLayoutItems.endIndex else {
                return nil
        }
        return self.visibleLayoutItems[index]
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override open func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.visibleLayoutItems.count
    }
    
    func generateString(key: String, element: JSON, state: RSState) -> String? {
        
        if let string: String = key <~~ element {
            return string
        }
        else if let json: JSON = key <~~ element,
            let valueConvertible = RSValueManager.processValue(jsonObject: json, state: state, context: [:]) {
            return valueConvertible.evaluate() as? String
        }
        
        return nil
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let item = self.itemForIndexPath(indexPath: indexPath),
            let state = self.state else {
            return tableView.dequeueReusableCell(withIdentifier: "text_only_cell", for: indexPath)
        }
        
        var cell: UITableViewCell!
        
        switch item.type {
        case "tappableItem":
            cell = tableView.dequeueReusableCell(withIdentifier: "activity_cell", for: indexPath)
            cell.textLabel?.text = RSApplicationDelegate.localizedString(self.generateString(key: "title", element: item.element, state: state))
            
        case "textItem":
            cell = tableView.dequeueReusableCell(withIdentifier: "text_only_cell", for: indexPath)
            cell.textLabel?.text = RSApplicationDelegate.localizedString(self.generateString(key: "title", element: item.element, state: state))
            cell.detailTextLabel?.text = RSApplicationDelegate.localizedString(self.generateString(key: "text", element: item.element, state: state))
            
        case "debugItem":
            cell = tableView.dequeueReusableCell(withIdentifier: "text_only_cell", for: indexPath)
            cell.textLabel?.text = RSApplicationDelegate.localizedString(self.generateString(key: "title", element: item.element, state: state))
            cell.detailTextLabel?.text = RSApplicationDelegate.localizedString(self.generateString(key: "text", element: item.element, state: state))
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDebugListItemTap))
            gestureRecognizer.numberOfTapsRequired = 8
            cell.addGestureRecognizer(gestureRecognizer)
            
        case "toggleItem":
            guard let toggleCell = tableView.dequeueReusableCell(withIdentifier: "toggle_cell", for: indexPath) as? RSToggleCell,
                let toggleItem = RSToggleListItem(json: item.element),
                let metadata = RSStateSelectors.getStateValueMetadata(state, for: toggleItem.boundStateIdentifier),
                metadata.type == "Boolean" else {
                break
            }
            
            toggleCell.title?.text = RSApplicationDelegate.localizedString(self.generateString(key: "title", element: item.element, state: state))
            
            toggleCell.onToggle = { isOn in
                let action = RSActionCreators.setValueInState(key: toggleItem.boundStateIdentifier, value: NSNumber(booleanLiteral: isOn))
                self.store?.dispatch(action)
            }
            
            if let value = RSStateSelectors.getValueInCombinedState(state, for: toggleItem.boundStateIdentifier) as? NSNumber {
                if toggleCell.toggle.isOn != value.boolValue {
                    toggleCell.toggle.setOn(value.boolValue, animated: true)
                }
            }
            else {
                if toggleCell.toggle.isOn == true {
                    toggleCell.toggle.setOn(false, animated: true)
                }
            }
            
            cell = toggleCell
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "text_only_cell", for: indexPath)
            cell.textLabel?.text = RSApplicationDelegate.localizedString(self.generateString(key: "title", element: item.element, state: state))
        }
        
        cell.tag = indexPath.row
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        //this helps in testing the CLVisit pathway
//        if let item = self.itemForIndexPath(indexPath: indexPath),
//            item.identifier == "visit" {
//            //simulate visit
//            let visit = RSVisit()
//
//            if let locationManager = RSApplicationDelegate.appDelegate.locationManager {
//                locationManager.locationManager(locationManager.locationManager, didVisit: visit)
//            }
//
//
//        }
        
        guard let item = self.itemForIndexPath(indexPath: indexPath),
            let tappableItem = RSTappableListItem(json: item.element) else {
            return
        }
        
        //dispatch onTap actions
        tappableItem.onTapActions.forEach { self.processAction(action: $0) }
        
    }
    
    @objc func handleDebugListItemTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let cell = sender.view as? UITableViewCell,
                let item = self.itemForRow(row: cell.tag) {
                
                if let debugActionsJSON: [JSON] = "debugActions" <~~ item.element {
                    //dispatch debug actions
                    debugActionsJSON.forEach { self.processAction(action: $0) }
                }
                
            }
        }
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
    
    public var childLayoutVCs: [RSLayoutViewController] = []
    
    public func childLayoutVC(for matchedRoute: RSMatchedRoute) -> RSLayoutViewController? {
        
        return childLayoutVCs.first(where: { (lvc) -> Bool in
            return lvc.matchedRoute.route.identifier == matchedRoute.route.identifier
        })
        
    }
    
    public func updateLayout(matchedRoute: RSMatchedRoute, state: RSState) {
        
    }
    
    

}
