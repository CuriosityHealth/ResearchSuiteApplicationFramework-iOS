//
//  RSCardCellSubtitleLabel.swift
//  Pods
//
//  Created by James Kizer on 5/25/18.
//

import UIKit
import ResearchSuiteExtensions

open class RSCardCellSubtitleLabel: RSLabel {
    
    override open var defaultFont: UIFont {
        return RSFonts.computeFont(startingTextStyle: UIFont.TextStyle.subheadline, defaultSize: 14.0, typeAdjustment: 14.0, weight: UIFont.Weight.light)
    }
    
}
