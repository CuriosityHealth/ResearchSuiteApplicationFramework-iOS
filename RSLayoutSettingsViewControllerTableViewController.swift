//
//  RSLayoutSettingsViewControllerTableViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/13/17.
//

import UIKit
import ReSwift
import Gloss

open class RSLayoutSettingsViewControllerTableViewController: UITableViewController, StoreSubscriber, RSLayoutViewControllerProtocol {

    weak var store: Store<RSState>?
    var state: RSState!
    var settingsLayout: RSSettingsLayout!
    open var layout: RSLayout! {
        return self.settingsLayout
    }
    
    var visibleLayoutItems: [RSListItem] = []
    
    override open func viewDidLoad() {
        super.viewDidLoad()

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
            RSActionManager.processAction(action: action, context: [:], store: store)
        }
    }
    
//    open func computeVisibleLayoutItems() -> [String] {
//        return self.listLayout.items.filter { self.shouldShowItem(item: $0) }.map { $0.identifier }
//    }
    
    open func newState(state: RSState) {
        
        self.state = state
        self.loadData(state: state)
        
        
    }
    
    @objc
    open func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.loadData(state: state)
        self.loadFinished()
    }
    
    func loadData(state: RSState) {
        
        
        //we should only reload cells if values bound by list item predicates have changed
        //but this is probably a premature optimization
//        let newVisibleLayoutItems = self.computeVisibleLayoutItems()
//        let currentVisibleLayoutItems = self.visibleLayoutItems.map { $0.identifier }
//        if newVisibleLayoutItems != currentVisibleLayoutItems {
//            self.visibleLayoutItems = newVisibleLayoutItems.flatMap { self.listLayout.itemMap[$0] }
//            self.loadFinished()
//        }
        
        
        self.visibleLayoutItems = []
        self.loadFinished()
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
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activity_cell", for: indexPath)
        
        guard let item = self.itemForIndexPath(indexPath: indexPath) else {
            return cell
        }
        cell.textLabel?.text = item.title
        
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let item = self.itemForIndexPath(indexPath: indexPath) else {
            return
        }
        
        //dispatch onTap actions
        item.onTapActions.forEach { self.processAction(action: $0) }
        
    }
    
    open func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            if let store = self.store {
                RSActionManager.processAction(action: action, context: ["layoutViewController":self], store: store)
            }
        })
        
    }
    
}
