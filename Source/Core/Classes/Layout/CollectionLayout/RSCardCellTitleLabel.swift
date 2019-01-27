//
//  RSCardCellTitleLabel.swift
//  Pods
//
//  Created by James Kizer on 5/25/18.
//

import UIKit
import ResearchSuiteExtensions

open class RSCardCellTitleLabel: RSLabel {
    
    override open var defaultFont: UIFont {
        return RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.headline, defaultSize: 17.0, typeAdjustment: 20.0, weight: UIFont.Weight.light)
    }
    
}
