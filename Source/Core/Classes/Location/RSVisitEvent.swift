//
//  RSVisitEvent.swift
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
import CoreLocation
import ResearchSuiteResultsProcessor

open class RSVisitEvent: RSRPIntermediateResult {
    
    public static let kType = "RSVisitEvent"
    
    open let visit: CLVisit
    open let timestamp: Date
    init(visit: CLVisit, source: String, uuid: UUID, timestamp: Date = Date()) {
        self.visit = visit
        self.timestamp = timestamp
        super.init(
            type: RSLocationEvent.kType,
            uuid: uuid,
            taskIdentifier: source,
            taskRunUUID: UUID()
        )
    }
    
}
