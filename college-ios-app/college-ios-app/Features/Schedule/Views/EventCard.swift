import SwiftUI

struct EventCard: View {
    let event: ScheduleEvent

    private var eventColor: Color {
        Color.accentColor 
    }

    private var eventTypeIcon: String {
        "book.fill"
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(event.start)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Text(event.end)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(width: 50)

            RoundedRectangle(cornerRadius: 3)
                .fill(eventColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: eventTypeIcon)
                        .font(.system(size: 12))
                        .foregroundColor(eventColor)

                    Text(event.topic)
                        .font(.system(size: 15, weight: .medium))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !event.title.isEmpty && event.title != event.topic {
                    Text(event.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 16) {
                    if !event.room.isEmpty && event.room != "—" {
                        Label(event.room, systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let subGroups = event.subGroups, !subGroups.isEmpty {
                        Label(formatSubgroups(subGroups), systemImage: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private func formatSubgroups(_ subGroups: [ScheduleSubGroup]) -> String {
        let titles = subGroups
            .map { !$0.sTitle.isEmpty ? $0.sTitle : $0.sTopic }
            .filter { !$0.isEmpty }

        if titles.isEmpty {
            return "Все"
        }
        return titles.joined(separator: ", ")
    }
}
