//
//  ScheduleWidget.swift
//  ScheduleWidget
//
//  Created by pc on 30.09.2025.
//

import WidgetKit
import SwiftUI

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
                hasValidSettings: entry.hasValidSettings,
                hasError: entry.hasError
            )
        case .systemLarge:
            LargeScheduleWidgetView(
                events: entry.events,
                currentDate: entry.date,
                hasValidSettings: entry.hasValidSettings,
                hasError: entry.hasError
            )
        default:
            Text("Не поддерживается")
        }
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

#Preview("С расписанием", as: .systemLarge) {
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

#Preview("Ошибка загрузки", as: .systemMedium) {
    ScheduleWidget()
} timeline: {
    ScheduleEntry(
        date: Date(),
        events: [],
        hasValidSettings: true,
        hasError: true
    )
}

#Preview("Без настроек", as: .systemMedium) {
    ScheduleWidget()
} timeline: {
    ScheduleEntry(
        date: Date(),
        events: [],
        hasValidSettings: false
    )
}
