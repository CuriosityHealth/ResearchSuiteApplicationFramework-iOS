//
//  RSReducer.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import ReSwift

public class RSReducer: NSObject {
    
    public static let reducer = CombinedReducer([
        ActivityReducer()
    ])
    
    final class ActivityReducer: Reducer {
        
        open func handleAction(action: Action, state: RSState?) -> RSState {
            
            let state = state ?? RSState.empty()
            
            switch action {
                
            case let addActivityAction as AddActivityAction:
                
                let activity = addActivityAction.activity
                var newActivityMap = state.activityMap
                newActivityMap[activity.identifier] = activity
                
                
                return RSState.newState(fromState: state, activityMap: newActivityMap)

            default:
                return state
            }
            
        }
        
    }
}
