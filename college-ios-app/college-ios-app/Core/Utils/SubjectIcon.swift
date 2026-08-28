//
//  SubjectIcon.swift
//  college-ios-app
//

import Foundation

nonisolated enum SubjectIcon {

    static func symbol(for title: String) -> String {
        let name = title.lowercased().replacingOccurrences(of: "ё", with: "е")
        func has(_ parts: String...) -> Bool { parts.contains { name.contains($0) } }

        if has("физкультур", "физическ", "спорт") { return "figure.run" }

        if (has("баз") && has("данн")) || has("субд", "sql") { return "cylinder.split.1x2" }
        if has("сет", "маршрутизац", "телекоммуникац") { return "network" }
        if has("операционн", "linux", "windows") { return "terminal" }
        if has("алгоритм", "структур данных", "дискретн") { return "arrow.triangle.branch" }
        if has("тестирован", "отладк", "качеств") { return "ladybug" }
        if has("мобильн", "android", "ios") { return "iphone" }
        if has("веб", "web", "сайт", "html", "фронтенд") { return "globe" }
        if has("криптограф")
            || (has("безопасн") && has("информ", "данн"))
            || (has("защит") && has("информ")) { return "lock.shield" }
        if has("разработ", "программ", "модул", "информатик") {
            return "chevron.left.forwardslash.chevron.right"
        }
        if has("аппаратн", "эвм", "архитектур", "схемотехник") { return "memorychip" }

        if has("русск", "литератур", "родн") { return "book" }
        if has("английск", "иностран", "язык") { return "character.book.closed" }

        if has("статистик", "вероятност") { return "chart.bar" }
        if has("математик", "матем", "численн метод") { return "function" }
        if has("астроном") { return "moon.stars" }
        if has("физик", "хими") { return "atom" }
        if has("биолог", "естествознан", "эколог") { return "leaf" }
        if has("географ") { return "map" }

        if has("истори") { return "clock.arrow.circlepath" }
        if has("обществ", "правов", "юрид", "законодат") { return "building.columns" }
        if has("психолог", "общени", "этик") { return "brain.head.profile" }
        if has("эконом", "финанс", "предпринимат", "бухгалт", "менеджмент", "маркетинг") {
            return "chart.line.uptrend.xyaxis"
        }

        if has("жизнедеятельн", "обж", "охран труда", "медицин") { return "cross.case" }
        if has("черчени", "график", "дизайн", "инженерн") { return "paintbrush.pointed" }
        if has("практик", "производствен", "стажировк") { return "briefcase" }
        if has("проект", "курсов", "диплом", "вкр") { return "doc.text" }
        if has("экзамен", "зачет", "консультац", "аттестац") { return "checkmark.seal" }
        if has("классн час", "куратор", "собрани") { return "person.3" }

        return "graduationcap"
    }
}
