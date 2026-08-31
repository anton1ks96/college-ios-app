//
//  SubjectIcon.swift
//  college-ios-app
//

import Foundation

nonisolated enum SubjectIcon {

    static func symbol(for title: String) -> String {
        if let symbol = icons[title] { return symbol }

        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed != title, let symbol = icons[trimmed] { return symbol }

        return keyword(for: trimmed)
    }

    private static func keyword(for title: String) -> String {
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

    // MARK: - Названия портала

    static let icons: [String: String] = [
        "Математика": "function",
        "ЭлВышМат": "x.squareroot",
        "ДискрМат": "point.3.connected.trianglepath.dotted",
        "ТеорВер": "die.face.5",
        "ЧислМетоды": "sum",
        "Физика": "atom",
        "Химия": "testtube.2",
        "Биология": "leaf",
        "Астрономия": "moon.stars",
        "История": "clock.arrow.circlepath",
        "Обществознание": "building.columns",
        "Философия": "brain",
        "РусЯз": "textformat.abc",
        "Литер": "book",
        "АнглЯз": "character.book.closed",
        "АнглЯзПро": "text.book.closed",
        "Физкульт": "figure.run",
        "Физкультура": "figure.run",
        "ОБиЗР": "cross.case",
        "ЭлДок": "doc.on.doc",
        "ФинГрамота": "rublesign.circle",
        "ПОПД": "scroll",
        "Предпринимат": "chart.line.uptrend.xyaxis",
        "ПсихОбщен": "brain.head.profile",
        "КритМыш": "lightbulb",
        "ИнжМыш": "gearshape.2",
        "АктМаст": "theatermasks",
        "ИстТехно": "hourglass",
        "ЛичБренд": "person.crop.circle.badge.checkmark",
        "КреативМ": "sparkles",
        "ТехДокиРус": "doc.richtext",
        "ОКРиУП": "list.clipboard",

        "РазработкаПО": "chevron.left.forwardslash.chevron.right",
        "ВведениеООП": "square.stack.3d.up",
        "ПрогрC#": "number.square",
        "АиСД": "arrow.triangle.branch",
        "Hardware": "memorychip",
        "ОперСистемы": "terminal",
        "КомпСети": "network",
        "СУБД": "cylinder.split.1x2",
        "СУБД-проектирование": "tablecells",
        "ИнфоБез": "lock.shield",
        "ОсновыML": "cpu",
        "АрхПаттерны3": "building.2",
        "ПарадигмыПроект": "compass.drawing",
        "React": "circle.hexagongrid",
        "UML-BE": "flowchart",
        "UML-FE": "flowchart.fill",
        "УчПроект.BE": "curlybraces",
        "УчПроект.FE": "macwindow",
        "МикросервисыBE": "square.split.2x2",
        "МикросервисыFE": "square.split.2x2.fill",
        "BE-Production": "externaldrive.connected.to.line.below",
        "Тестирование": "ladybug",
        "ТестИнтерф": "checkmark.rectangle",
        "ТестИнтерфейс": "checkmark.rectangle",
        "ТестИнтерфейсов": "checkmark.rectangle",
        "РазрИнтерф": "rectangle.and.pencil.and.ellipsis",
        "ИнстРазрИнтерф": "wrench.and.screwdriver",
        "РазрИгрИнтерф": "dpad",

        "Веб-Дизайн": "globe",
        "ГрафДизайн": "paintbrush.pointed",
        "ДизИнтерфейсов": "rectangle.3.group",
        "ДизДиджитал": "ipad.and.iphone",
        "ДизМедиа": "photo.on.rectangle.angled",
        "СтилиДизайн": "swatchpalette",
        "Композиция": "rectangle.split.3x3",
        "Колористика": "paintpalette",
        "2D-КомпГраф": "square.on.circle",
        "3D-КомпГраф": "cube.transparent",
        "3D-Интерфейсы": "rotate.3d",
        "UX/UI дизайн": "rectangle.and.hand.point.up.left",
        "АналитикаUX": "chart.pie",

        "GameDev-2(1)": "gamecontroller",
        "GameDev-2(2)": "gamecontroller.fill",
        "GameDev-3(3)": "arcade.stick",
        "GameDev-практ": "l.joystick",
        "РазработкаИгрП": "puzzlepiece",
        "РевьюКодаGD": "doc.text.magnifyingglass",
        "РевьюИгроКейс2": "magnifyingglass.circle",
        "РевьюИгроКейс3": "magnifyingglass.circle.fill",
        "МаркетингGD": "megaphone",

        "Проект": "doc.text",
        "Проект-3": "doc.on.clipboard",
        "ПрофПредмет": "star.square",
        "ВведСпец": "signpost.right",
        "УпрИТ-проект": "list.bullet.clipboard",
        "ВидыПроект": "rectangle.stack",
        "ФормПроекта": "doc.badge.plus",
        "КейсыПроектов": "folder",
        "ПроектированиеБП": "rectangle.connected.to.line.below",
        "ПроектыБП": "chart.bar.doc.horizontal",
        "ПсихологияБП": "person.2.circle",
        "МаркетингПМ": "megaphone.fill",
        "ИТ-инфр-проект": "server.rack",
        "ИТ-инфр-разв": "cable.connector",
        "ИТ-инфр-экспл": "wrench.and.screwdriver.fill",

        "ПроизвПракт.01": "briefcase",
        "УчПракт03": "hammer",
        "УчПракт04": "hammer",
        "УчПракт06": "hammer",
        "УчПракт.БП": "hammer.circle",
        "УчПракт.UI": "hammer.fill",
        "Демоэкзамен": "checkmark.seal",
        "Предзащита": "hand.raised",
        "Нормоконтроль": "text.magnifyingglass",
        "В.Сборы": "shield.lefthalf.filled",
        "Буткемп": "tent",
        "Выставка": "photo.artframe",
        "ФорумБудущего": "bubble.left.and.bubble.right",
        "ОргСобрание": "person.3",
        "Подгруппы": "list.bullet.indent",
        "Подгруппы-2к": "2.square",
        "Подгруппы-3к": "3.square",
        "АлгоТруд-3": "person.text.rectangle",
    ]
}
