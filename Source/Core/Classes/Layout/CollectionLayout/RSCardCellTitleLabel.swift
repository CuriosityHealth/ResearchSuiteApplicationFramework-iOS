//
//  RSCardCellTitleLabel.swift
//  Pods
//
//  Created by James Kizer on 5/25/18.
//

import UIKit
import ResearchSuiteExtensions

open class RSCardCellTitleLabel: RSLabel {
    
    override open var defaultWeight: UIFont.Weight {
        return .light
    }
    
    override open var defaultFont: UIFont {
        let weight: UIFont.Weight = self.weightOverride ?? self.defaultWeight
        return RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.headline, defaultSize: 17.0, typeAdjustment: 20.0, weight: weight)
    }
    
}
