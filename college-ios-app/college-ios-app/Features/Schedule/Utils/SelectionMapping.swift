//
//  SelectionMapping.swift
//  college-ios-app
//

import Foundation

nonisolated enum SelectionMapping {

    static func selection(of user: User) -> Selection? {
        guard let group = user.academicGroup, Groups.all.contains(group) else { return nil }

        let subgroups = Groups.subgroups(of: group)
        let isFirstYear = subgroups.contains { $0.id.hasPrefix("Подгр") }
        let subgroup = (isFirstYear ? user.subgroup : user.profile)
            .flatMap { id in subgroups.contains { $0.id == id } ? id : nil }

        let profileSubgroups = Groups.profileSubgroups(of: group, subgroup: subgroup)
        let profileSubgroup = user.subgroup
            .flatMap { id in profileSubgroups.contains { $0.id == id } ? id : nil }

        let englishGroup = user.englishGroup
            .flatMap { Groups.englishGroups(of: group).contains($0) ? $0 : nil }

        return Selection(
            group: group,
            subgroup: subgroup,
            englishGroup: englishGroup,
            profileSubgroup: profileSubgroup
        )
    }
}
