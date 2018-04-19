//
//  RSPromise.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/9/18.
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
