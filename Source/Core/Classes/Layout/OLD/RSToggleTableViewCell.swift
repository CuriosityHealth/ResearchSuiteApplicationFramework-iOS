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
    
    @IBOutlet weak var toggle: UISwitch!
    @IBOutlet weak var title: UILabel!
    open var onToggle: ((Bool)->())?
    
    @IBAction func valueChanged(_ sender: UISwitch) {
        self.onToggle?(sender.isOn)
    }
    

}
