//
//  RSTask.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 1/1/18.
//

import UIKit
import ResearchKit

public protocol RSTask: ORKTask {
    var shouldHideCancelButton: Bool { get }
}

extension ORKOrderedTask: RSTask {
    public var shouldHideCancelButton: Bool {
        return false
    }
}
