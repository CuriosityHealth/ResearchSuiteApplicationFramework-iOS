//
//  RSLayoutButton.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 7/6/17.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Gloss

open class RSLayoutButton: Gloss.JSONDecodable {
    
    public let identifier: String
    public let title: String?
    public let image: UIImage?
    public let colorJSON: JSON?
    public let predicate: RSPredicate?
    public let onTapActions: [JSON]
    public let element: JSON
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.title = "title" <~~ json
        self.image = {
            guard let imageString: String = "image" <~~ json else {
                    return nil
            }
            
            return UIImage(named: imageString)
        }()
        self.predicate = "predicate" <~~ json
        self.onTapActions = "onTap" <~~ json ?? []
        self.element = json
        self.colorJSON = "color" <~~ json
    }

}
