//
//  DateFormatters.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import Foundation

struct DateFormatters {
    static let request: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()

    static let uiDate: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d MMM, EEE"
        df.locale = Locale(identifier: "ru_RU")
        return df
    }()

    static let uiTime: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
}
