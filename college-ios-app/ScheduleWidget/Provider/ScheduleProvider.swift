//
//  ScheduleProvider.swift
//  ScheduleWidget
//
//  Created by pc on 03.10.2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    private let adapter: WidgetScheduleAdapter

    init(adapter: WidgetScheduleAdapter = WidgetScheduleAdapter()) {
        self.adapter = adapter
    }
    
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(date: Date(), events: [], hasValidSettings: false)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> ()) {
        let hasValidSettings = adapter.hasValidSettings()
        let events = hasValidSettings ? adapter.loadTodayEvents() : []
        let entry = ScheduleEntry(date: Date(), events: events, hasValidSettings: hasValidSettings)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> ()) {
        let hasValidSettings = adapter.hasValidSettings()
        let events = hasValidSettings ? adapter.loadTodayEvents() : []
        let entry = ScheduleEntry(date: Date(), events: events, hasValidSettings: hasValidSettings)
        
        let nextUpdate = calculateNextUpdate(for: events)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func calculateNextUpdate(for events: [ScheduleEvent]) -> Date {
        let now = Date()
        
        guard !events.isEmpty else {
            return WidgetScheduleBridge.shared.calculateNextNightUpdate()
        }
        
        let sortedEvents = events.sorted { a, b in
            guard let timeA = parseTime(a.start, on: now),
                  let timeB = parseTime(b.start, on: now) else {
                return a.start < b.start
            }
            return timeA < timeB
        }
        
        for event in sortedEvents {
            guard let startTime = parseTime(event.start, on: now),
                  let endTime = parseTime(event.end, on: now) else {
                continue
            }
            
            if now >= startTime && now < endTime {
                return endTime
            }
            
            if now < startTime {
                return startTime
            }
        }
        
        return WidgetScheduleBridge.shared.calculateNextNightUpdate()
    }
    
    private func parseTime(_ timeString: String, on date: Date) -> Date? {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return nil
        }
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date)
    }
}

// MARK: - Entry

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let events: [ScheduleEvent]
    let hasValidSettings: Bool
}
