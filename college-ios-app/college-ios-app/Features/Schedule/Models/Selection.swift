//
//  Selection.swift
//  college-ios-app
//

import Foundation

nonisolated struct Selection: Equatable, Sendable {
    var group: String
    var subgroup: String?
    var englishGroup: String?
    var profileSubgroup: String?

    init(
        group: String,
        subgroup: String? = nil,
        englishGroup: String? = nil,
        profileSubgroup: String? = nil
    ) {
        self.group = group
        self.subgroup = subgroup
        self.englishGroup = englishGroup
        self.profileSubgroup = profileSubgroup
    }

    var label: String {
        [group, subgroup, profileSubgroup, englishGroup]
            .compactMap { $0 }
            .joined(separator: " · ")
    }
}
