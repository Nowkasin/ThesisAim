//
//  TimeRange.swift
//  BeActive
//
//  Created by Kasin Thappawan on 25/2/2568 BE.
//

import Foundation

enum TimeRange: String, CaseIterable {
    case today = "today"
    case week = "week"
    case month = "month"
    case sixMonths = "sixMonths"
    case year = "year"
    
    var localized: String {
           return t(self.rawValue, in: "Chart.Time")
       }
}

