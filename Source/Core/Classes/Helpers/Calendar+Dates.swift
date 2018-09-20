//
//  Calendar+Dates.swift
//  Alamofire
//
//  Created by James Kizer on 9/20/18.
//

import Foundation

public extension Calendar {
    public func dates(
        from startDate: Date,
        until endDate: Date,
        matching dateComponents: DateComponents,
        matchingPolicy: Calendar.MatchingPolicy = .strict,
        repeatedTimePolicy: Calendar.RepeatedTimePolicy = .first,
        direction: Calendar.SearchDirection = .forward
        ) -> [Date] {
        var matchingDates: [Date] = []
        
        self.enumerateDates(startingAfter: startDate, matching: dateComponents, matchingPolicy: .strict , using: { (date, match, stop) in
            
            if let date = date,
                match == true,
                date <= endDate {
                
                matchingDates = matchingDates + [date]
                
            }
            else {
                stop = true
            }
            
        })
        
        return matchingDates
    }
}
