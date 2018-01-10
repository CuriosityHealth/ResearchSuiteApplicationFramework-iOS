//
//  RSLayoutTableViewController.swift
//  Pods
//
//  Created by James Kizer on 7/3/17.
//
//

import UIKit
import ReSwift
import Gloss
import CoreLocation

open class RSLayoutTableViewController: UITableViewController, StoreSubscriber, RSLayoutViewControllerProtocol {

    weak var store: Store<RSState>?
    var state: RSState!
    var lastState: RSState!
    var listLayout: RSListLayout!
    open var layout: RSLayout! {
        return self.listLayout
    }
    
    var visibleLayoutItems: [RSListItem] = []
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        //process on load actions
//        self.layout.onLoadActions.forEach { self.processAction(action: $0) }
        
        self.navigationItem.title = self.layout.navTitle
        if let rightButton = self.layout.navButtonRight {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightButton.title, style: .plain, target: self, action: #selector(tappedRightBarButton))
        }
        
        self.store?.subscribe(self)

        self.refreshControl?.addTarget(self, action: #selector(RSLayoutTableViewController.handleRefresh(_:)), for: .valueChanged)
    }
    
    deinit {
        self.store?.unsubscribe(self)
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
    
    open func processAction(action: JSON) {
        if let store = self.store {
            RSActionManager.processAction(action: action, context: ["layoutViewController":self], store: store)
        }
    }
    
    open func computeVisibleLayoutItems() -> [String] {
        return self.listLayout.items.filter { self.shouldShowItem(item: $0) }.map { $0.identifier }
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
        self.loadData(state: state)
        self.loadFinished()
    }
    
    func loadData(state: RSState) {
        
        
        //we should only reload cells if values bound by list item predicates have changed
        //but this is probably a premature optimization
        let newVisibleLayoutItems = self.computeVisibleLayoutItems()
        let currentVisibleLayoutItems = self.visibleLayoutItems.map { $0.identifier }
        if newVisibleLayoutItems != currentVisibleLayoutItems {
            self.visibleLayoutItems = newVisibleLayoutItems.flatMap { self.listLayout.itemMap[$0] }
            self.loadFinished()
            return
        }
        
        
        
        
    }
    
    func loadFinished() {
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
    open func shouldShowItem(item: RSListItem) -> Bool {
        guard let predicate = item.predicate else {
            return true
        }
        
        return RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
    }
    
    open func itemForIndexPath(indexPath: IndexPath) -> RSListItem? {
        let index = indexPath.row
        
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
    
    func generateString(key: String, element: JSON) -> String? {
        
        if let string: String = key <~~ element {
            return string
        }
        else if let json: JSON = key <~~ element,
            let valueConvertible = RSValueManager.processValue(jsonObject: json, state: self.state, context: [:]) {
            return valueConvertible.evaluate() as? String
        }
        
        return nil
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let item = self.itemForIndexPath(indexPath: indexPath) else {
            return tableView.dequeueReusableCell(withIdentifier: "text_only_cell", for: indexPath)
        }
        
        var cell: UITableViewCell!
        
        switch item.type {
        case "tappableItem":
            cell = tableView.dequeueReusableCell(withIdentifier: "activity_cell", for: indexPath)
            cell.textLabel?.text = self.generateString(key: "title", element: item.element)
            
        case "textItem":
            cell = tableView.dequeueReusableCell(withIdentifier: "text_only_cell", for: indexPath)
            cell.textLabel?.text = self.generateString(key: "title", element: item.element)
            cell.detailTextLabel?.text = self.generateString(key: "text", element: item.element)
            
        case "toggleItem":
            guard let toggleCell = tableView.dequeueReusableCell(withIdentifier: "toggle_cell", for: indexPath) as? RSToggleCell,
                let toggleItem = RSToggleListItem(json: item.element),
                let metadata = RSStateSelectors.getStateValueMetadata(self.state, for: toggleItem.boundStateIdentifier),
                metadata.type == "Boolean" else {
                break
            }
            
            toggleCell.title?.text = self.generateString(key: "title", element: item.element)
            
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
            cell.textLabel?.text = self.generateString(key: "title", element: item.element)
        }
        
        
        
//        if item.onTapActions.count > 0 {
//            cell = tableView.dequeueReusableCell(withIdentifier: "activity_cell", for: indexPath)
//        }
//        else {
//            cell = tableView.dequeueReusableCell(withIdentifier: "text_only_cell", for: indexPath)
//        }
//
//        cell.textLabel?.text = self.generateString(key: "title", element: item.element)
//        cell.detailTextLabel?.text = self.generateString(key: "text", element: item.element)

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
    
    open func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            if let store = self.store {
                RSActionManager.processAction(action: action, context: ["layoutViewController":self], store: store)
            }
        })
        
    }

}
