//
//  ClassDetails.swift
//  college-ios-app
//

import Foundation

nonisolated struct DetailRow: Identifiable, Equatable, Sendable {
    let key: String
    let value: String

    var id: String { "\(key)-\(value)" }
}

nonisolated indirect enum JSONValue: Decodable, Sendable {
    case object([String: JSONValue])
    case array([JSONValue])
    case string(String)
    case number(Double)
    case bool(Bool)
    case null

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: AnyKey.self) {
            var object: [String: JSONValue] = [:]
            for key in container.allKeys {
                object[key.stringValue] = try container.decode(JSONValue.self, forKey: key)
            }
            self = .object(object)
            return
        }
        if var container = try? decoder.unkeyedContainer() {
            var array: [JSONValue] = []
            while !container.isAtEnd {
                array.append(try container.decode(JSONValue.self))
            }
            self = .array(array)
            return
        }
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else {
            self = .string(try container.decode(String.self))
        }
    }

    private struct AnyKey: CodingKey {
        let stringValue: String
        var intValue: Int? { nil }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }
}

nonisolated extension JSONValue {

    static let hiddenKeys: Set<String> = [
        "ClID", "SClID", "Day", "start", "end",
        "title", "topic", "room", "group", "color", "type",
    ]

    func detailRows() -> [DetailRow] {
        var rows: [DetailRow] = []
        walk(key: "", into: &rows)
        return rows
    }

    private func walk(key: String, into rows: inout [DetailRow]) {
        switch self {
        case .object(let object):
            for (name, value) in object.sorted(by: { $0.key < $1.key }) {
                value.walk(key: name, into: &rows)
            }
        case .array(let array):
            for value in array {
                value.walk(key: key, into: &rows)
            }
        case .string(let text):
            append(key: key, text: text, into: &rows)
        case .number(let number):
            let text = number == number.rounded() && abs(number) < 1e15
                ? String(Int(number))
                : String(number)
            append(key: key, text: text, into: &rows)
        case .bool(let flag):
            append(key: key, text: flag ? "да" : "нет", into: &rows)
        case .null:
            break
        }
    }

    private func append(key: String, text: String, into rows: inout [DetailRow]) {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !Self.hiddenKeys.contains(key), !value.isEmpty, value != "null", value != "—" else { return }
        rows.append(DetailRow(key: key, value: value))
    }
}
