//
//  RSLayoutManager.swift
//  Pods
//
//  Created by James Kizer on 7/1/17.
//
//

import UIKit
import ReSwift

public class RSLayoutManager: NSObject {
    
    //layout manager needs to sense chagnes to the store
    //reevaluate to see if the layout changes
    //if the layout changes, need to instantiate the new layout view controller
    //tell delegate to present new view controller
    
    let layoutGenerators: [RSLayoutGenerator.Type]
    
    public init(
        layoutGenerators: [RSLayoutGenerator.Type]?
    ) {
        self.layoutGenerators = layoutGenerators ?? []
        super.init()
    }
    
    public func generateLayout(layout: RSLayout, store: Store<RSState>) -> UIViewController? {
        for layoutGenerator in layoutGenerators {
            if layoutGenerator.supportsType(type: layout.type),
                let layoutVC = layoutGenerator.generateLayout(jsonObject: layout.element, store: store, layoutManager: self) {
                return layoutVC
            }
        }
        return nil
    }
}
