//
//  ORKResult+Extensions.swift
//  Alamofire
//
//  Created by James Kizer on 8/5/19.
//

import Foundation
import ResearchKit

extension ORKTaskResult {
    public func firstResult<T: ORKResult>(forStepIdentifier: String) -> T? {
        return self.stepResult(forStepIdentifier: forStepIdentifier)?.firstResult as? T
    }
}
