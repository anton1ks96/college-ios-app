//
//  HomeMocks.swift
//  college-ios-app
//

#if DEBUG
import Foundation

nonisolated final class MockHomeRepository: HomeRepositoryProtocol {

    private let delay: Duration
    private let failure: Error?

    init(delay: Duration = .milliseconds(350), failure: Error? = nil) {
        self.delay = delay
        self.failure = failure
    }

    func attendance(monday: Date) async throws -> [AttendanceRecord] {
        try? await Task.sleep(for: delay)
        if let failure { throw failure }
        return HomeMocks.records(monday: monday)
    }

    func streak() async throws -> Streak {
        try? await Task.sleep(for: delay)
        if let failure { throw failure }
        return HomeMocks.streak
    }

    func subjects() async throws -> [Subject] {
        try? await Task.sleep(for: delay)
        if let failure { throw failure }
        return HomeMocks.subjects
    }

    func scores(subjectID: String, start: Date, end: Date) async throws -> [SubjectLesson] {
        try? await Task.sleep(for: delay)
        if let failure { throw failure }
        return HomeMocks.lessons
    }
}

nonisolated enum HomeMocks {

    static let user = User(
        id: "i24s0291",
        username: "i24s0291",
        role: "student",
        academicGroup: "ИТ-307",
        profile: "Программист",
        subgroup: "Подгруппа 1",
        englishGroup: "B1.21"
    )

    static let streak = Streak(
        current: 5,
        longest: 9,
        daysAttended: 40,
        schoolDays: 45,
        lastAttended: ScheduleCalendar.day(of: .now),
        periodStart: HomeSemester.bounds(for: .now).start,
        periodEnd: HomeSemester.bounds(for: .now).end
    )

    static let subjects = [
        Subject(id: "1", title: "Разработка программных модулей"),
        Subject(id: "2", title: "Базы данных"),
        Subject(id: "3", title: "Операционные системы"),
        Subject(id: "4", title: "Иностранный язык"),
        Subject(id: "5", title: "Математика"),
        Subject(id: "6", title: "Физическая культура"),
    ]

    static let lessons = [
        SubjectLesson(
            title: "Практическая работа",
            scores: [
                Score(id: "p0", date: day(-21), value: 5, max: 5, details: "Вёрстка макета"),
                Score(id: "p1", date: day(-14), value: 3, max: 5, details: "Формы и валидация"),
                Score(id: "p2", date: day(-7), value: 4, max: 5, details: ""),
            ]
        ),
        SubjectLesson(
            title: "Самостоятельная работа",
            scores: [
                Score(id: "s0", date: day(-10), value: 2, max: 5, details: "Опрос по теме"),
                Score(id: "s1", date: day(-3), value: nil, max: 5, details: "Реферат"),
            ]
        ),
    ]

    static func records(monday: Date) -> [AttendanceRecord] {
        let current = ScheduleCalendar.monday(of: .now)
        let weeks = ScheduleCalendar.calendar
            .dateComponents([.weekOfYear], from: current, to: monday)
            .weekOfYear ?? 0
        guard abs(weeks) <= 1 else { return [] }

        return plan.flatMap { offset, lessons in
            let date = ScheduleCalendar.adding(days: offset, to: monday)
            return lessons.enumerated().map { index, lesson in
                AttendanceRecord(
                    id: "\(ScheduleParsing.requestString(from: date))-\(index)",
                    date: date,
                    start: slots[index].0,
                    end: slots[index].1,
                    title: lesson.0,
                    topic: lesson.1,
                    room: lesson.2,
                    attendance: lesson.3
                )
            }
        }
    }

    private static func day(_ offset: Int) -> Date {
        ScheduleCalendar.adding(days: offset, to: ScheduleCalendar.day(of: .now))
    }

    private static let slots: [(Int, Int)] = [
        (9 * 60, 10 * 60 + 30),
        (10 * 60 + 40, 12 * 60 + 10),
        (12 * 60 + 40, 14 * 60 + 10),
        (14 * 60 + 20, 15 * 60 + 50),
    ]

    private static let plan: [(Int, [(String, String, String, Attendance)])] = [
        (0, [
            ("Разработка программных модулей", "Паттерны проектирования", "305", .present),
            ("Базы данных", "Индексы и планы запросов", "412", .present),
            ("Математика", "Производная сложной функции", "210", .present),
            ("Иностранный язык", "Present Perfect", "118", .present),
        ]),
        (1, [
            ("Операционные системы", "Права доступа", "305", .present),
            ("Физическая культура", "", "Спортзал", .excused),
            ("Разработка программных модулей", "Рефакторинг", "305", .present),
            ("Базы данных", "Транзакции", "412", .present),
        ]),
        (3, [
            ("Математика", "Интегралы", "210", .present),
            ("Разработка программных модулей", "Тестирование модулей", "305", .present),
            ("Иностранный язык", "Технический перевод", "118", .absent),
            ("Операционные системы", "Процессы и потоки", "305", .present),
        ]),
        (4, [
            ("Базы данных", "Нормализация", "412", .present),
            ("Физическая культура", "", "Спортзал", .absent),
            ("Разработка программных модулей", "Курсовой проект", "305", .present),
            ("Математика", "Ряды", "210", .excused),
        ]),
    ]
}
#endif
