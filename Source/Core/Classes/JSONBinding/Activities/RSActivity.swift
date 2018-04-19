//
//  RSActivity.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 6/24/17.
//
//
// Copyright 2018, Curiosity Health Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
