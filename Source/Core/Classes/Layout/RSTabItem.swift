//
//  RSTabItem.swift
//  Pods
//
//  Created by James Kizer on 7/9/17.
//
//

import UIKit
import Gloss

open class RSTabItem: Gloss.JSONDecodable {
    
    public let identifier: String
    public let title: String
    public let shortTitle: String
    public let imageTitle: String?
    public let selectedImageTitle: String?
    public let predicate: RSPredicate?
    public let onTapActions: [JSON]
    public let element: JSON
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let title: String = "title" <~~ json,
            let shortTitle: String = "shortTitle" <~~ json else {
                return nil
        }
        
        self.identifier = identifier
        self.title = title
        self.shortTitle = shortTitle
        self.imageTitle = "image" <~~ json
        self.selectedImageTitle = "selectedImage" <~~ json
        self.predicate = "predicate" <~~ json
        self.onTapActions = "onTap" <~~ json ?? []
        self.element = json
    }

}
