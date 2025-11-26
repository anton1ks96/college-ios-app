//
//  StreakStorage.swift
//  college-ios-app
//
//  Created by pc on 26.11.2025.
//

import Foundation

final class StreakStorage: Sendable {
    private let defaults: UserDefaults
    private let lastKnownStreakKey = "streak.lastKnownStreak"
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    var lastKnownStreak: Int? {
        get { defaults.object(forKey: lastKnownStreakKey) as? Int }
        set { defaults.set(newValue, forKey: lastKnownStreakKey) }
    }
    
    func calculateIncrease(newStreak: Int) -> Int {
        guard let last = lastKnownStreak else {
            return newStreak
        }
        return max(0, newStreak - last)
    }
    
    func updateLastKnown(_ streak: Int) {
        lastKnownStreak = streak
    }

    func clear() {
        lastKnownStreak = nil
    }
}
