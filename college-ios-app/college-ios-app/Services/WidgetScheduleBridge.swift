//
//  WidgetScheduleBridge.swift
//  college-ios-app
//
//  Created by pc on 01.10.2025.
//

import Foundation
import WidgetKit

final class WidgetScheduleBridge {

    // MARK: - Constants
    private enum Keys {
        static let cachedSchedule = "widget_cached_schedule"
        static let lastUpdated = "widget_schedule_last_updated"
        static let nextScheduledUpdate = "widget_next_scheduled_update"
    }

    // MARK: - Properties
    private let defaults: UserDefaults?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    // MARK: - Singleton
    static let shared = WidgetScheduleBridge()

    // MARK: - Init
    init(suiteName: String = "group.com.college.MyKCT") {
        self.defaults = UserDefaults(suiteName: suiteName)
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    // MARK: - Public API

    func saveSchedule(_ events: [ScheduleEvent]) {
        guard let data = try? encoder.encode(events) else {
            print("Failed to encode schedule events")
            return
        }

        defaults?.set(data, forKey: Keys.cachedSchedule)
        defaults?.set(Date(), forKey: Keys.lastUpdated)

        print("Schedule saved to cache: \(events.count) events")

        reloadWidget()
    }

    func loadSchedule() -> [ScheduleEvent]? {
        guard let data = defaults?.data(forKey: Keys.cachedSchedule) else {
            print("No cached schedule found")
            return nil
        }

        guard let events = try? decoder.decode([ScheduleEvent].self, from: data) else {
            print("Failed to decode cached schedule")
            return nil
        }

        print("Schedule loaded from cache: \(events.count) events")
        return events
    }

    func shouldRefresh() -> Bool {
        guard let lastUpdate = defaults?.object(forKey: Keys.lastUpdated) as? Date else {
            print("No last update date, refresh needed")
            return true
        }

        let dayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let shouldRefresh = lastUpdate < dayAgo

        if shouldRefresh {
            print("Last update: \(lastUpdate), refresh needed")
        } else {
            print("Cache is fresh, no refresh needed")
        }

        return shouldRefresh
    }

    func lastUpdateDate() -> Date? {
        return defaults?.object(forKey: Keys.lastUpdated) as? Date
    }

    func clearCache() {
        defaults?.removeObject(forKey: Keys.cachedSchedule)
        defaults?.removeObject(forKey: Keys.lastUpdated)
        defaults?.removeObject(forKey: Keys.nextScheduledUpdate)

        print("Schedule cache cleared")

        reloadWidget()
    }

    func setNextScheduledUpdate(_ date: Date) {
        defaults?.set(date, forKey: Keys.nextScheduledUpdate)
        print("Next scheduled update: \(date)")
    }

    func getNextScheduledUpdate() -> Date? {
        return defaults?.object(forKey: Keys.nextScheduledUpdate) as? Date
    }

    func calculateNextNightUpdate() -> Date {
        let calendar = Calendar.current
        let now = Date()

        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else {
            return calendar.date(byAdding: .hour, value: 24, to: now)!
        }

        guard let nextUpdate = calendar.date(bySettingHour: 3, minute: 0, second: 0, of: tomorrow) else {
            return calendar.date(byAdding: .hour, value: 24, to: now)!
        }

        return nextUpdate
    }

    // MARK: - Widget Integration

    private func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "ScheduleWidget")
        print("Widget reload triggered")
    }
}
