//
//  RSCompositeCollectionDataSourceDescriptor.swift
//  Pods
//
//  Created by James Kizer on 5/29/18.
//

import UIKit
import Gloss

open class RSCompositeCollectionDataSourceDescriptor: RSCollectionDataSourceDescriptor {
    
    public let childDescriptors: [RSCollectionDataSourceDescriptor]
    
    required public init?(json: JSON) {
        guard let childDescriptorsJSON: [JSON] = "childDescriptors" <~~ json else {
                return nil
        }
        
        self.childDescriptors = childDescriptorsJSON.compactMap { RSCollectionDataSourceDescriptor(json: $0) }
        super.init(json: json)
    }

}
