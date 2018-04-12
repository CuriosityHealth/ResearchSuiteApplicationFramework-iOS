//
//  RSMatchedRoute.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
//

import UIKit

public struct RSMatchedRoute: Equatable {
    public static func == (lhs: RSMatchedRoute, rhs: RSMatchedRoute) -> Bool {
        return lhs.layout.isEqualTo(rhs.layout) && lhs.match == rhs.match && lhs.route == rhs.route
    }
    
    let match: RSMatch
    let route: RSRoute
    let layout: RSLayout
    
}
