//
//  TextLessons.swift
//  college-ios-app
//
//  Created by pc on 16.11.2025.
//

import Foundation

enum TextLessons {
    static func lessons(_ count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "занятий"
        }
        
        switch lastDigit {
        case 1:
            return "пара"
        case 2, 3, 4:
            return "пары"
        default:
            return "пар"
        }
    }
}
