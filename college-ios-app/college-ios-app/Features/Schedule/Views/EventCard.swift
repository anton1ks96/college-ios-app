import SwiftUI

struct EventCard: View {
    let event: ScheduleEvent
    @State private var isSubgroupsExpanded = false
    
    private var eventColor: Color { .accentColor }
    
    private var eventTypeIcon: String {
        switch event.type {
        case "2": "person.2.fill"
        default: "book.fill"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                        
                        Text(event.title)
                            .font(.system(size: 15, weight: .medium))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    if !event.topic.isEmpty {
                        Text(event.topic)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 12) {
                        if !event.room.isEmpty, event.room != "—", (event.subGroups?.isEmpty ?? true) {
                            LocationBadge(text: event.room)
                        }
                        
                        if let subGroups = event.subGroups, !subGroups.isEmpty {
                            SubgroupsToggleButton(
                                count: subGroups.count,
                                isExpanded: $isSubgroupsExpanded,
                                eventColor: eventColor
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            
            if isSubgroupsExpanded, let subGroups = event.subGroups, !subGroups.isEmpty {
                VStack(spacing: 0) {
                    Divider().background(Color(.separator).opacity(0.3))
                    
                    VStack(spacing: 6) {
                        ForEach(subGroups) { subgroup in
                            SubgroupRow(subgroup: subgroup)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                }
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                ))
            }
        }
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Utils

struct LocationBadge: View {
    let text: String
    
    var body: some View {
        Label(text, systemImage: "location.fill")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

struct SubgroupsToggleButton: View {
    let count: Int
    @Binding var isExpanded: Bool
    let eventColor: Color
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "person.2.fill").font(.caption)
                Text("\(count) \(subgroupsText(count))")
                    .font(.caption.weight(.medium))
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10))
            }
            .foregroundColor(eventColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(eventColor.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    private func subgroupsText(_ count: Int) -> String {
        switch count {
        case 1: return "подгруппа"
        case 2, 3, 4: return "подгруппы"
        default: return "подгрупп"
        }
    }
}

struct SubgroupRow: View {
    let subgroup: ScheduleSubGroup

    private var formattedGroupID: String {
        GroupTypeFormatter.format(subgroup.sGrID)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(formattedGroupID)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                
                if !subgroup.sTitle.isEmpty {
                    Text(subgroup.sTitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if !subgroup.sGCaID.isEmpty, subgroup.sGCaID != "—" {
                LocationBadge(text: subgroup.sGCaID)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemFill))
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

