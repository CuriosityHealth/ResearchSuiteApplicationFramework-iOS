//
//  RSTask.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/1/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import ResearchKit

public protocol RSTask: ORKTask {
    var shouldHideCancelButton: Bool { get }
    var shouldConfirmCancel: Bool { get }
}

extension ORKOrderedTask: RSTask {
    public var shouldHideCancelButton: Bool {
        return false
    }
    
    public var shouldConfirmCancel: Bool {
        return true
    }
}
