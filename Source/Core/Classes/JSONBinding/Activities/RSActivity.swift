//
//  RSActivity.swift
//  Pods
//
//  Created by James Kizer on 6/24/17.
//
//

import UIKit
import Gloss
import ReSwift

public class RSActivity: Gloss.JSONDecodable {
    
    public struct OnCompletionStruct {
        //TODO: Make this better
        let onSuccessActions: [JSON]
        let onFailureActions: [JSON]
        let finallyActions: [JSON]
    }
    
    let identifier: String
    let elements: [JSON]
    let onLaunchActions: [JSON]?
    let onCompletion: OnCompletionStruct
    let shouldHideCancelButton: Bool
    
    required public init?(json: JSON) {
        
        guard let identifier: String = "identifier" <~~ json,
            let elements: [JSON] = "elements" <~~ json,
            let onCompletion: JSON = "onCompletion" <~~ json,
            let onSuccess: [JSON] = "onSuccess" <~~ onCompletion,
            let onFailure: [JSON] = "onFailure" <~~ onCompletion,
            let finally: [JSON] = "finally" <~~ onCompletion else {
                return nil
        }
        
        self.identifier = identifier
        self.elements = elements
        self.onLaunchActions = "onLaunch" <~~ json
        
        self.onCompletion = OnCompletionStruct(
            onSuccessActions: onSuccess,
            onFailureActions: onFailure,
            finallyActions: finally
        )
        
        self.shouldHideCancelButton = "hideCancelButton" <~~ json ?? false
        
    }
    
    
    

}
