//
//  RSTitleLayout.swift
//  Pods
//
//  Created by James Kizer on 7/6/17.
//
//

import UIKit
import Gloss

open class RSTitleLayout: RSLayout {
    
    public let title: String
    public let image: UIImage
    public let button: RSLayoutButton
    
    required public init?(json: JSON) {
        
        guard let title: String = "title" <~~ json,
            let imageTitle: String = "image" <~~ json,
            let image = UIImage(named: imageTitle),
            let button: RSLayoutButton = "button" <~~ json else {
                return nil
        }

        self.title = title
        self.image = image
        self.button = button
        
        super.init(json: json)
    }
    
}
