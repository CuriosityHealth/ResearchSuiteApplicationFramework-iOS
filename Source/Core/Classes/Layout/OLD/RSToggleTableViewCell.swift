//
//  RSToggleTableViewCell.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit

open class RSToggleCell: UITableViewCell {
    
    @IBOutlet public weak var toggle: UISwitch!
    @IBOutlet public weak var title: UILabel!
    open var onToggle: ((Bool)->())?
    
    @IBAction public func valueChanged(_ sender: UISwitch) {
        self.onToggle?(sender.isOn)
    }
    

}
