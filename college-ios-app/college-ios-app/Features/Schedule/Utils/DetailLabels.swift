//
//  DetailLabels.swift
//  college-ios-app
//

import Foundation

nonisolated enum DetailLabels {

    static func title(for key: String) -> String {
        known.first { $0.key == key.lowercased() }?.title ?? key
    }

    static func sorted(_ rows: [DetailRow]) -> [DetailRow] {
        rows.enumerated()
            .sorted { left, right in
                let ranks = (rank(of: left.element.key), rank(of: right.element.key))
                return ranks.0 == ranks.1 ? left.offset < right.offset : ranks.0 < ranks.1
            }
            .map(\.element)
    }

    private static func rank(of key: String) -> Int {
        known.firstIndex { $0.key == key.lowercased() } ?? known.count
    }

    private static let known: [(key: String, title: String)] = [
        ("teacher", "Преподаватель"),
        ("topicdescr", "Тема"),
        ("topictitle", "Занятие"),
        ("descr", "Описание"),
        ("building", "Корпус"),
        ("comment", "Комментарий"),
    ]
}
