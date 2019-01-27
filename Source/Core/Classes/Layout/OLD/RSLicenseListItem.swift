//
//  RSLicenseListItem.swift
//  Pods
//
//  Created by James Kizer on 1/22/19.
//

import UIKit
import Gloss

open class RSLicenseListItem: RSListItem {
    
    public let acknowledgementsFile: String
    
    required public init?(json: JSON) {
        guard let acknowledgementsFile: String = "acknowledgementsFile" <~~ json else {
            return nil
        }
        
        self.acknowledgementsFile = acknowledgementsFile
        super.init(json: json)
    }
    
}
