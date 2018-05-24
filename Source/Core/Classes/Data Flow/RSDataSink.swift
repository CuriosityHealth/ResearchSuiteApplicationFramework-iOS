//
//  RSDataSink.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 5/9/18.
//

import UIKit
import LS2SDK

//Does this protocol replace our RSRPBackEnd protocol?
//Support actions like "sendResultToServer" -> "sinkData"
//We would also want to support local database(s) and HealthKit
public protocol RSDataSink {
    
    func add(datapoint: RSDatapoint)
    func add(datapoints: [RSDatapoint])

}
