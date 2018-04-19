//
//  RSVisit.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/10/18.
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


// THIS CLASS IS USED FOR TESTING PURPOSES ONLY!!!!!
// HELPS IN TESTING THE CLVisit PATHWAY
// CLVisit is all get-only, so we override eveything and we can send to
// locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit)
open class RSVisit: CLVisit {
    
    var _arrivalDate: Date
    override open var arrivalDate: Date {
        get {
            return _arrivalDate
        }
        set (newVal) {
            _arrivalDate = newVal
        }
    }
    
    var _departureDate: Date
    override open var departureDate: Date {
        get {
            return _departureDate
        }
        set (newVal) {
            _departureDate = newVal
        }
    }
    
    var _coordinate: CLLocationCoordinate2D
    override open var coordinate: CLLocationCoordinate2D {
        get {
            return _coordinate
        }
        set (newVal) {
            _coordinate = newVal
        }
    }
    
    var _horizontalAccuracy: CLLocationAccuracy
    override open var horizontalAccuracy: CLLocationAccuracy {
        get {
            return _horizontalAccuracy
        }
        set (newVal) {
            _horizontalAccuracy = newVal
        }
    }
    
    override init() {
        self._arrivalDate = Date().addingTimeInterval(TimeInterval(60.0*60.0))
        self._departureDate = Date()
        let coordinate = CLLocationCoordinate2DMake(51.50998, -0.1337)
        self._coordinate = coordinate
        self._horizontalAccuracy = 5
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
