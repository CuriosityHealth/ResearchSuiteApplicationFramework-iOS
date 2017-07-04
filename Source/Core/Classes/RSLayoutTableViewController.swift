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

class RSLayoutTableViewController: UITableViewController, StoreSubscriber {

    var store: Store<RSState>!
    var state: RSState!
    var layout: RSListLayout!
    
    var visibleLayoutItems: [RSListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //process on load actions
        self.layout.onLoadActions.forEach { self.processAction(action: $0) }
        
        self.store.subscribe(self)

        self.refreshControl?.addTarget(self, action: #selector(RSLayoutTableViewController.handleRefresh(_:)), for: .valueChanged)
    }
    
    deinit {
        self.store.unsubscribe(self)
    }
    
    open func processAction(action: JSON) {
        RSActionManager.processAction(action: action, context: [:], store: self.store)
    }
    
    open func computeVisibleLayoutItems() -> [String] {
        return self.layout.items.filter { self.shouldShowItem(item: $0) }.map { $0.identifier }
    }
    
    open func newState(state: RSState) {
        
        self.state = state
        self.loadData(state: state)
        
        
    }
    
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
            self.visibleLayoutItems = newVisibleLayoutItems.flatMap { self.layout.itemMap[$0] }
            self.loadFinished()
        }
        
    }
    
    func loadFinished() {
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
    open func shouldShowItem(item: RSListItem) -> Bool {
        //if predicate doesn't exist, return true
        //otherwise evaluate predicate
        return true
    }
    
    open func itemForIndexPath(indexPath: IndexPath) -> RSListItem? {
        let index = indexPath.row
        
        guard index >= self.visibleLayoutItems.startIndex,
            index < self.visibleLayoutItems.endIndex else {
                return nil
        }
        return self.visibleLayoutItems[index]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.visibleLayoutItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

}
