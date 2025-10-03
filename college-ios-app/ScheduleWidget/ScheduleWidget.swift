//
//  ScheduleWidget.swift
//  ScheduleWidget
//
//  Created by pc on 30.09.2025.
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

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
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

// MARK: - Widget View

struct ScheduleWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium:
            MediumScheduleWidgetView(
                events: entry.events,
                currentDate: entry.date,
                hasValidSettings: entry.hasValidSettings
            )
        case .systemLarge:
            LargeScheduleWidgetView(events: entry.events)
        default:
            Text("Не поддерживается")
        }
    }
}

// MARK: - Medium Widget View

struct MediumScheduleWidgetView: View {
    let events: [ScheduleEvent]
    let currentDate: Date
    let hasValidSettings: Bool

    private var currentTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: currentDate)
    }

    // MARK: - Time helpers

    private func time(_ hhmm: String, on base: Date) -> Date? {
        let comps = hhmm.split(separator: ":")
        guard comps.count == 2,
              let h = Int(comps[0]), let m = Int(comps[1]) else { return nil }
        return Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: base)
    }

    private var orderedEvents: [ScheduleEvent] {
        events.sorted { a, b in
            guard let sa = time(a.start, on: currentDate),
                  let sb = time(b.start, on: currentDate) else { return a.start < b.start }
            return sa < sb
        }
    }

    private var pivotIndex: Int? {
        guard !orderedEvents.isEmpty else { return nil }
        let now = currentDate
        if let i = orderedEvents.firstIndex(where: { ev in
            guard let s = time(ev.start, on: now), let e = time(ev.end, on: now) else { return false }
            return now >= s && now <= e
        }) {
            return i
        }
        if let i = orderedEvents.firstIndex(where: { ev in
            guard let s = time(ev.start, on: now) else { return false }
            return s > now
        }) {
            return i
        }
        return nil
    }

    private var currentEvent: ScheduleEvent? {
        guard let i = pivotIndex else { return nil }
        return orderedEvents[i]
    }

    private var visibleEvents: [ScheduleEvent] {
        guard let i = pivotIndex else { return [] }
        return Array(orderedEvents[i...].prefix(2))
    }

    var body: some View {
        if !hasValidSettings {
            VStack(spacing: 12) {
                Spacer()
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.orange)

                VStack(spacing: 4) {
                    Text("Настройте виджет")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    Text("Откройте приложение и выберите группу, подгруппу и группу английского")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                Spacer()
            }
        } else {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Расписание")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        Image(systemName: "calendar")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                            .padding(6)
                            .background(
                                Circle().fill(Color.blue.opacity(0.1))
                            )
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                    Divider()
                }
                .frame(maxWidth: .infinity)
                .background(Color.clear)

                VStack(spacing: 8) {
                    if visibleEvents.isEmpty {
                        Spacer()
                        VStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                            Text("Пар нет")
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                            Text("Расписание обновится ночью")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    } else {
                        ForEach(visibleEvents) { event in
                            EventRow(event: event, isFirst: event.id == currentEvent?.id)
                        }
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            }
        }
    }
}

// MARK: - Event Row

struct EventRow: View {
    let event: ScheduleEvent
    let isFirst: Bool

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .trailing, spacing: 2) {
                Text(event.start)
                    .font(.system(size: 13, weight: isFirst ? .semibold : .regular))
                    .foregroundColor(isFirst ? .blue : .primary)

                Text(event.end)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }


            RoundedRectangle(cornerRadius: 1)
                .fill(isFirst ? Color.blue : Color.gray.opacity(0.3))
                .frame(width: 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 13, weight: isFirst ? .semibold : .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Label(event.room, systemImage: "location.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)

                    if !event.topic.isEmpty {
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)

                        Text(event.topic)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isFirst ? Color.blue.opacity(0.08) : Color.clear)
        )
    }
}

// MARK: - Large Widget View

struct LargeScheduleWidgetView: View {
    let events: [ScheduleEvent]

    var body: some View {
        VStack {
            Text("Large Widget")
                .font(.title2)
            Text("Coming soon...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Widget Configuration

struct ScheduleWidget: Widget {
    let kind: String = "ScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ScheduleWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Расписание")
        .description("Показывает расписание занятий на сегодня")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Previews

#Preview(as: .systemMedium) {
    ScheduleWidget()
} timeline: {
    ScheduleEntry(
        date: Calendar.current.date(
            bySettingHour: 10,
            minute: 50,
            second: 0,
            of: Date()
        ) ?? Date(),
        events: [
            ScheduleEvent(
                clID: "1",
                type: "Лекция",
                day: DateFormatters.request.string(from: Date()),
                group: "ИСП-11",
                topic: "Математический анализ",
                start: "09:00",
                end: "10:30",
                room: "101",
                color: "#FF5733",
                title: "Высшая математика",
                subGroups: nil
            ),
            ScheduleEvent(
                clID: "2",
                type: "Практика",
                day: DateFormatters.request.string(from: Date()),
                group: "ИСП-11",
                topic: "Разработка iOS приложений",
                start: "10:45",
                end: "12:15",
                room: "202",
                color: "#33C1FF",
                title: "Мобильная разработка",
                subGroups: nil
            ),
            ScheduleEvent(
                clID: "3",
                type: "Лабораторная",
                day: DateFormatters.request.string(from: Date()),
                group: "ИСП-11",
                topic: "SQL запросы",
                start: "13:00",
                end: "14:30",
                room: "303",
                color: "#33FF57",
                title: "Базы данных",
                subGroups: nil
            )
        ],
        hasValidSettings: true
    )
}
