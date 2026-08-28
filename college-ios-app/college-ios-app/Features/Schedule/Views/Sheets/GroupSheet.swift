//
//  GroupSheet.swift
//  college-ios-app
//

import SwiftUI

struct GroupSheet: View {
    let selection: Selection
    let onSelect: (Selection) -> Void

    private var subgroups: [Groups.Named] { Groups.subgroups(of: selection.group) }
    private var profileSubgroups: [Groups.Named] {
        Groups.profileSubgroups(of: selection.group, subgroup: selection.subgroup)
    }
    private var englishGroups: [String] { Groups.englishGroups(of: selection.group) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SelectionSection(title: "Группа") {
                    ForEach(Groups.all, id: \.self) { group in
                        SelectionChip(title: group, isSelected: group == selection.group) {
                            onSelect(selection.withGroup(group))
                        }
                    }
                }

                SelectionSection(title: "Подгруппа") {
                    SelectionChip(title: "Все", isSelected: selection.subgroup == nil) {
                        onSelect(selection.withSubgroup(nil))
                    }
                    ForEach(subgroups) { subgroup in
                        SelectionChip(title: subgroup.title, isSelected: subgroup.id == selection.subgroup) {
                            onSelect(selection.withSubgroup(subgroup.id))
                        }
                    }
                }

                if !profileSubgroups.isEmpty {
                    SelectionSection(title: "Подгруппа профиля") {
                        SelectionChip(title: "Все", isSelected: selection.profileSubgroup == nil) {
                            onSelect(updating(\.profileSubgroup, to: nil))
                        }
                        ForEach(profileSubgroups) { subgroup in
                            SelectionChip(
                                title: subgroup.title,
                                isSelected: subgroup.id == selection.profileSubgroup
                            ) {
                                onSelect(updating(\.profileSubgroup, to: subgroup.id))
                            }
                        }
                    }
                }

                if !englishGroups.isEmpty {
                    SelectionSection(title: "Английский") {
                        SelectionChip(title: "Все", isSelected: selection.englishGroup == nil) {
                            onSelect(updating(\.englishGroup, to: nil))
                        }
                        ForEach(englishGroups, id: \.self) { group in
                            SelectionChip(title: group, isSelected: group == selection.englishGroup) {
                                onSelect(updating(\.englishGroup, to: group))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Metrics.screenPadding)
            .padding(.bottom, 32)
        }
        .appBackground()
    }

    private func updating(_ key: WritableKeyPath<Selection, String?>, to value: String?) -> Selection {
        var updated = selection
        updated[keyPath: key] = value
        return updated
    }
}

#Preview {
    GroupSheet(selection: ScheduleMocks.selection, onSelect: { _ in })
        .environment(\.colors, .dark)
}
