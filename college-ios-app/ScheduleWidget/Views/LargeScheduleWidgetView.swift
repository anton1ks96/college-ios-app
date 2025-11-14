//
//  LargeScheduleWidgetView.swift
//  ScheduleWidget
//
//  Created by pc on 03.10.2025.
//

import SwiftUI

struct LargeScheduleWidgetView: View {
    let events: [ScheduleEvent]
    let currentDate: Date
    let hasValidSettings: Bool
    let hasError: Bool
    
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
    
    var body: some View {
        if hasError {
            ErrorStateView()
        } else if !hasValidSettings {
            VStack(spacing: 12) {
                Spacer()
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                
                VStack(spacing: 4) {
                    Text("Настройте виджет")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Откройте приложение и выберите группу, подгруппу и группу английского")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                Spacer()
            }
        } else {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Расписание на сегодня")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("AccentColor"))
                            .padding(8)
                            .background(
                                Circle().fill(Color("AccentColor").opacity(0.1))
                            )
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    
                    Divider()
                }
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                
                if orderedEvents.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        Text("Пар нет")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        Text("Расписание обновится ночью")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                } else {
                    VStack(spacing: 6) {
                        ForEach(orderedEvents) { event in
                            EventRow(event: event, isFirst: event.id == currentEvent?.id)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
        }
    }
}
