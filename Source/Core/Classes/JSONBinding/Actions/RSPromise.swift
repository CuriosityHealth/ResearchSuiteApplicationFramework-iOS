//
//  RSPromise.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
//

import UIKit
import Gloss

public struct RSPromise: Gloss.JSONDecodable {
    
    //TODO: Make this better
    let onSuccessActions: [JSON]?
    let onFailureActions: [JSON]?
    let finallyActions: [JSON]?
    
    public init?(json: JSON) {
        self.onSuccessActions = "onSuccess" <~~ json
        self.onFailureActions = "onFailure" <~~ json
        self.finallyActions = "finally" <~~ json
    }
}
