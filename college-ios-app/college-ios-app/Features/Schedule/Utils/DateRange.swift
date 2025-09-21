//
//   DateRange.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import Foundation

struct DateRange {
    var start: Date
    var end: Date

    init(start: Date, end: Date) {
        if end < start {
            self.start = end
            self.end = start
        } else {
            self.start = start
            self.end = end
        }
    }
}
