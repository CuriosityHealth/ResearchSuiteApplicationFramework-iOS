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
    public let image: UIImage?
    public let button: RSLayoutButton?
    
    required public init?(json: JSON) {
        
        guard let title: String = "title" <~~ json else {
                return nil
        }

        self.title = title
        
        self.image = {
            if let imageTitle: String = "image" <~~ json {
                return UIImage(named: imageTitle)
            }
            else {
                return nil
            }
        }()
        
        self.button = "button" <~~ json
        
        super.init(json: json)
    }
    
}
