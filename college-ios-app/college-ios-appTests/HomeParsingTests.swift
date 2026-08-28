//
//  HomeParsingTests.swift
//  college-ios-appTests
//

import Testing
import Foundation
@testable import college_ios_app

private let decoder = JSONDecoder()

private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
    try decoder.decode(type, from: Data(json.utf8))
}

@Suite("Разбор посещаемости")
struct AttendanceParsingTests {

    @Test("Голый null вместо массива читается как пустой список")
    func nullResponse() throws {
        let decoded = try decode([AttendanceDTO]?.self, "null")
        #expect((decoded ?? []).isEmpty)
    }

    @Test("Отсутствующие поля не роняют разбор")
    func missingFields() throws {
        let dto = try decode(AttendanceDTO.self, #"{"Day": "2026-08-24"}"#)

        #expect(dto.title.isEmpty)
        #expect(dto.status == -1)
        #expect(HomeParsing.record(from: dto)?.attendance == .unknown)
    }

    @Test("Идентификатор приходит и числом, и строкой")
    func identifier() throws {
        #expect(try decode(AttendanceDTO.self, #"{"ClID": 42}"#).clID == "42")
        #expect(try decode(AttendanceDTO.self, #"{"ClID": "42"}"#).clID == "42")
    }

    @Test("Прочерк вместо кабинета превращается в пустую строку")
    func dash() throws {
        let dto = try decode(AttendanceDTO.self, #"{"Day": "2026-08-24", "room": "—"}"#)
        #expect(HomeParsing.record(from: dto)?.room == "")
    }

    @Test("Запись без разбираемой даты выбрасывается")
    func brokenDate() throws {
        let dto = try decode(AttendanceDTO.self, #"{"Day": "не дата", "title": "Математика"}"#)
        #expect(HomeParsing.record(from: dto) == nil)
    }

    @Test("Время читается из даты со временем")
    func time() throws {
        let dto = try decode(
            AttendanceDTO.self,
            #"{"Day": "2026-08-24", "start": "2026-08-24 9:00", "end": "2026-08-24 10:30"}"#
        )
        let record = HomeParsing.record(from: dto)

        #expect(record?.start == 540)
        #expect(record?.end == 630)
    }

    @Test("Записи сортируются по дате и началу пары")
    func sorting() throws {
        let dtos = try decode([AttendanceDTO].self, """
        [
          {"ClID": 3, "Day": "2026-08-25", "start": "2026-08-25 9:00"},
          {"ClID": 2, "Day": "2026-08-24", "start": "2026-08-24 12:40"},
          {"ClID": 1, "Day": "2026-08-24", "start": "2026-08-24 9:00"},
          {"ClID": 0, "Day": "сломано"}
        ]
        """)

        #expect(HomeParsing.records(from: dtos).map(\.id) == ["1", "2", "3"])
    }

    @Test("Дни группируются по возрастанию даты")
    func grouping() throws {
        let dtos = try decode([AttendanceDTO].self, """
        [
          {"ClID": 1, "Day": "2026-08-25", "status": 2},
          {"ClID": 2, "Day": "2026-08-24", "status": 2},
          {"ClID": 3, "Day": "2026-08-24", "status": 0}
        ]
        """)
        let days = HomeParsing.days(from: HomeParsing.records(from: dtos))

        #expect(days.count == 2)
        #expect(days[0].records.count == 2)
        #expect(days[0].present == 1)
        #expect(days[0].date < days[1].date)
    }
}

@Suite("Разбор баллов")
struct ScoresParsingTests {

    @Test("Вложенная карта разбирается в занятия, отсортированные по названию")
    func nested() throws {
        let response = try decode(ScoresResponse.self, """
        {
          "Разработка": {
            "Самостоятельная": [{"Score": "3", "MaxScore": 5, "Description": "Опрос"}],
            "Практическая": [{"Score": "5", "MaxScore": 5, "DateF": "2026-08-24T00:00:00"}]
          }
        }
        """)
        let lessons = HomeParsing.lessons(from: response)

        #expect(lessons.map(\.title) == ["Практическая", "Самостоятельная"])
        #expect(lessons[0].scores.first?.value == 5)
        #expect(lessons[0].scores.first?.date == ScheduleParsing.date(from: "2026-08-24"))
    }

    @Test("Пустой ответ даёт пустой список")
    func empty() throws {
        #expect(HomeParsing.lessons(from: try decode(ScoresResponse.self, "{}")).isEmpty)
    }

    @Test("Неоценённая работа читается как отсутствие балла")
    func notGraded() throws {
        let response = try decode(ScoresResponse.self, """
        {
          "Предмет": {
            "Занятие": [
              {"Score": "", "MaxScore": 5},
              {"Score": "—", "MaxScore": 5},
              {"Score": "4", "MaxScore": 5}
            ]
          }
        }
        """)
        let scores = HomeParsing.lessons(from: response).first?.scores ?? []

        #expect(scores.map(\.value) == [nil, nil, 4])
        #expect(scores.compactMap(\.value).count == 1)
    }

    @Test("Предмет берётся детерминированно, битая ветка пропускается")
    func brokenBranch() throws {
        let response = try decode(ScoresResponse.self, """
        {
          "Алгебра": {
            "Занятие": [{"Score": "4", "MaxScore": 5}],
            "Сломанное": "не массив"
          },
          "Геометрия": {"Занятие": [{"Score": "2", "MaxScore": 5}]}
        }
        """)
        let lessons = HomeParsing.lessons(from: response)

        #expect(lessons.map(\.title) == ["Занятие"])
        #expect(lessons[0].scores.first?.value == 4)
    }

    @Test("Средний балл считается без неоценённых работ")
    func average() {
        let scores = SubjectScores(
            subject: Subject(id: "1", title: "Разработка"),
            lessons: [
                SubjectLesson(title: "Практическая", scores: [
                    Score(id: "0", date: nil, value: 5, max: 5, details: ""),
                    Score(id: "1", date: nil, value: 4, max: 5, details: ""),
                    Score(id: "2", date: nil, value: nil, max: 5, details: ""),
                ]),
            ],
            isLoading: false
        )

        #expect(scores.graded.count == 2)
        #expect(scores.average == 4.5)
    }
}
