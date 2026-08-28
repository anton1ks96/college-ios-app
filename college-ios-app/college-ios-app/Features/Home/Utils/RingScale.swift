//
//  RingScale.swift
//  college-ios-app
//

import Foundation

nonisolated enum RingScale {

    static let tickCount = 48

    struct Bounds: Equatable, Sendable {
        let present: Int
        let excused: Int
        let absent: Int
    }

    static func bounds(for stats: AttendanceStats) -> Bounds {
        guard stats.total > 0 else { return Bounds(present: 0, excused: 0, absent: 0) }

        return Bounds(
            present: stats.present * tickCount / stats.total,
            excused: (stats.present + stats.excused) * tickCount / stats.total,
            absent: (stats.present + stats.excused + stats.absent) * tickCount / stats.total
        )
    }
}
