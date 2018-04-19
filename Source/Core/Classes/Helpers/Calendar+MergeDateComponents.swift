//
//  Calendar+MergeDateComponents.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 11/24/17.
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

import Foundation

extension Calendar {
    
    public func dateComponents(_ components:Set<Calendar.Component>, mergeFrom: DateComponents, mergeInto: DateComponents) -> DateComponents {
        var mutableMergeInto = mergeInto
        components.forEach { (component) in
            mutableMergeInto.setValue(mergeFrom.value(for: component), for: component)
        }
        return mutableMergeInto
        
    }
    
    public func dateComponents(_ components:Set<Calendar.Component>, mergeFrom: Date, mergeInto: DateComponents) -> DateComponents {
        
        return self.dateComponents(
            components,
            mergeFrom: self.dateComponents(components, from: mergeFrom),
            mergeInto: mergeInto
        )
        
    }
    
//    public enum Component {
//
//        case era
//
//        case year
//
//        case month
//
//        case day
//
//        case hour
//
//        case minute
//
//        case second
//
//        case weekday
//
//        case weekdayOrdinal
//
//        case quarter
//
//        case weekOfMonth
//
//        case weekOfYear
//
//        case yearForWeekOfYear
//
//        case nanosecond
//
//        case calendar
//
//        case timeZone
//    }
    
    public func component(fromComponentString: String) -> Calendar.Component? {
        switch fromComponentString {
        case "era":
            return .era
        case "year":
            return .year
        case "month":
            return .month
        case "day":
            return .day
        case "hour":
            return .hour
        case "minute":
            return .minute
        case "second":
            return .second
        case "weekday":
            return .weekday
        case "weekdayOrdinal":
            return .weekdayOrdinal
        case "quarter":
            return .quarter
        case "weekOfMonth":
            return .weekOfMonth
        case "weekOfYear":
            return .weekOfYear
        case "yearForWeekOfYear":
            return .yearForWeekOfYear
        case "nanosecond":
            return .nanosecond
        case "calendar":
            return .calendar
        case "timeZone":
            return .timeZone
            
        default:
            return nil
        }
    }
    
}
