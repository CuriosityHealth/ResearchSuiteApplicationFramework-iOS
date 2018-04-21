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
    
    let match: RSMatch
    let route: RSRoute
    let layout: RSLayout
    
}
