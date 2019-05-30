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
    var taskViewController: ORKTaskViewController? { get set }
}

extension ORKOrderedTask: RSTask {
    public var taskViewController: ORKTaskViewController? {
        get {
            return nil
        }
        set {
            
        }
    }
    
    public var shouldHideCancelButton: Bool {
        return false
    }
    
    public var shouldConfirmCancel: Bool {
        return true
    }
    
}
