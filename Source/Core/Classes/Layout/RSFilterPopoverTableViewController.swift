//
//  RSFilterPopoverTableViewController.swift
//  Pods
//
//  Created by James Kizer on 5/28/18.
//

import UIKit
import ResearchKit

public struct RSFilterPopoverItem: Hashable {
    public let identifier: String
    public let prompt: String
}

open class RSFilterPopoverTableViewCell: UITableViewCell {
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        self.imageView?.isHidden = !selected
        super.setSelected(selected, animated: animated)
    }
}

open class RSFilterPopoverTableViewController: UITableViewController {

    var items: [(RSFilterPopoverItem, Bool)]?
    open var onClick: ((RSFilterPopoverItem, Bool) -> ())?
    open var onDismiss: (([(RSFilterPopoverItem, Bool)]?) -> ())?
    static var checkImage: UIImage?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Filter"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView.register(RSFilterPopoverTableViewCell.self, forCellReuseIdentifier: "filterCell")
        self.tableView.allowsMultipleSelection = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        
        RSFilterPopoverTableViewController.checkImage = UIImage(named: "checkmark", in: Bundle(for: ORKStep.self), compatibleWith: nil)
    }
    
    @objc func done() {
        
        if let selectedPaths = self.tableView.indexPathsForSelectedRows,
            let oldItems = self.items {
            let updatedItems: [(RSFilterPopoverItem, Bool)] = oldItems.enumerated().map({ (offset, pair) -> (RSFilterPopoverItem, Bool) in
                let indexPath = IndexPath(row: offset, section: 0)
                return (pair.0, selectedPaths.contains(indexPath))
            })
            self.onDismiss?(updatedItems)
        }
        else {
            self.onDismiss?(nil)
        }
    }
    
    @objc func cancel() {
        self.onDismiss?(nil)
    }

    open func update(items: [(RSFilterPopoverItem, Bool)]) {
        self.items = items
        self.tableView.reloadData()
        items.enumerated().forEach { (offset, pair) in
            
            if pair.1 {
                self.tableView.selectRow(at: IndexPath(row: offset, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.top)
            }
            
        }
    }

    open override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items?.count ?? 0
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.items![indexPath.row]
        
        var cell : UITableViewCell!
        let cellIdentifier = "filterCell"
        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        cell.selectionStyle = .none
        
        let localizedString = RSApplicationDelegate.localizedString(item.0.prompt)
        cell.textLabel?.text = localizedString
        cell.imageView?.image = RSFilterPopoverTableViewController.checkImage
        
        return cell
    }

}
