//
//  ScheduleStores.swift
//  college-ios-app
//

import Foundation

nonisolated enum ScheduleDefaultsKey {
    static let group = "schedule.group"
    static let subgroup = "schedule.subgroup"
    static let englishGroup = "schedule.englishGroup"
    static let profileSubgroup = "schedule.profileSubgroup"
    static let view = "schedule.view"
    static let skipWeekends = "schedule.skipWeekends"
}

struct SelectionStore {

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> Selection {
        let stored = defaults.string(forKey: ScheduleDefaultsKey.group)
        let group = Groups.all.contains(stored ?? "") ? stored! : Selection.fallback.group
        return Selection(
            group: group,
            subgroup: defaults.string(forKey: ScheduleDefaultsKey.subgroup),
            englishGroup: defaults.string(forKey: ScheduleDefaultsKey.englishGroup),
            profileSubgroup: defaults.string(forKey: ScheduleDefaultsKey.profileSubgroup)
        )
    }

    func save(_ selection: Selection) {
        defaults.set(selection.group, forKey: ScheduleDefaultsKey.group)
        defaults.set(selection.subgroup, forKey: ScheduleDefaultsKey.subgroup)
        defaults.set(selection.englishGroup, forKey: ScheduleDefaultsKey.englishGroup)
        defaults.set(selection.profileSubgroup, forKey: ScheduleDefaultsKey.profileSubgroup)
    }
}

struct ScheduleSettingsStore {

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> ScheduleSettings {
        ScheduleSettings(
            view: defaults.string(forKey: ScheduleDefaultsKey.view)
                .flatMap(ScheduleView.init(rawValue:)) ?? ScheduleSettings().view,
            skipWeekends: defaults.bool(forKey: ScheduleDefaultsKey.skipWeekends)
        )
    }
}
