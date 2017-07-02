//
//  RSLayoutManager.swift
//  Pods
//
//  Created by James Kizer on 7/1/17.
//
//

import UIKit
import ReSwift

public protocol RSLayoutManagerDelegate: class {
    func presentLayout(viewController: UIViewController)
}

public class RSLayoutManager: NSObject, StoreSubscriber {
    
    //layout manager needs to sense chagnes to the store
    //reevaluate to see if the layout changes
    //if the layout changes, need to instantiate the new layout view controller
    //tell delegate to present new view controller
    
    let layoutGenerators: [RSLayoutGenerator.Type]
    let store: Store<RSState>
    var layoutID: String?
    weak var delegate: RSLayoutManagerDelegate?
    
    public init(
        layoutGenerators: [RSLayoutGenerator.Type]?,
        store: Store<RSState>,
        delegate: RSLayoutManagerDelegate
    ) {
        
        self.layoutGenerators = layoutGenerators ?? []
        self.store = store
        self.delegate = delegate
        
        super.init()
        
        store.subscribe(self)
    }
    
    deinit {
        self.store.unsubscribe(self)
    }

    public func newState(state: RSState) {
        
        
        
        
    }
}
