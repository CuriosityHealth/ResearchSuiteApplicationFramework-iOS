//
//  RSMatchedRoute.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/11/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit

public struct RSMatchedRoute: Equatable {
    public static func == (lhs: RSMatchedRoute, rhs: RSMatchedRoute) -> Bool {
        return lhs.layout.isEqualTo(rhs.layout) && lhs.match == rhs.match && lhs.route == rhs.route
    }
    
    public let match: RSMatch
    public let route: RSRoute
    public let layout: RSLayout
    
}
