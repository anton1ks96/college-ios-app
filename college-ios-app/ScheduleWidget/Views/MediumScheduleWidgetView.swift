//
//  MediumScheduleWidgetView.swift
//  ScheduleWidget
//
//  Created by pc on 03.10.2025.
//

import SwiftUI

struct MediumScheduleWidgetView: View {
    let events: [ScheduleEvent]
    let currentDate: Date
    let hasValidSettings: Bool
    
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
                        .fixedSize(horizontal: false, vertical: true)
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
                            .foregroundColor(Color("AccentColor"))
                            .padding(6)
                            .background(
                                Circle().fill(Color("AccentColor").opacity(0.1))
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
