//
//  LessonSplitting.swift
//  college-ios-app
//

import Foundation

nonisolated enum LessonSplitting {

    static let maxParallel = 3

    static func split(_ lessons: [Lesson], selection: Selection) -> [Lesson] {
        lessons.flatMap { lesson in
            isOwn(lesson, selection: selection)
                ? lesson.subgroups.map { lesson.withSubgroup($0) }
                : [lesson]
        }
    }

    static func selectedIDs(_ selection: Selection) -> Set<String> {
        Set(
            [selection.subgroup, selection.englishGroup, selection.profileSubgroup]
                .compactMap { $0 }
                .filter { !$0.isEmpty && $0 != "*" }
        )
    }

    private static func isOwn(_ lesson: Lesson, selection: Selection) -> Bool {
        guard (2...maxParallel).contains(lesson.subgroups.count) else { return false }

        let selected = selectedIDs(selection)
        guard !selected.isEmpty else { return false }

        return lesson.subgroups.allSatisfy { selected.contains($0.id) }
    }
}
