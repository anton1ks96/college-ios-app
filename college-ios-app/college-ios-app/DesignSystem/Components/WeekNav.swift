//
//  WeekNav.swift
//  college-ios-app
//

import SwiftUI

private let arrowSize: CGFloat = 44

struct WeekNav: View {
    @Environment(\.colors) private var colors

    let onToday: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        GlassGroup {
            HStack(spacing: 10) {
                Button(action: onToday) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Сегодня")
                            .textStyle(AppType.labelLarge)
                    }
                    .foregroundStyle(colors.onBackground)
                    .padding(.leading, 16)
                    .padding(.trailing, 20)
                    .padding(.vertical, 11)
                }
                .buttonStyle(.plain)
                .glassSurface(Capsule(), interactive: true)

                Spacer(minLength: 12)

                arrow("chevron.left", label: "Предыдущая неделя", action: onPrevious)
                arrow("chevron.right", label: "Следующая неделя", action: onNext)
            }
        }
    }

    private func arrow(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(colors.onBackground)
                .frame(width: arrowSize, height: arrowSize)
        }
        .buttonStyle(.plain)
        .glassSurface(Circle(), interactive: true)
        .accessibilityLabel(label)
    }
}

#Preview {
    WeekNav(onToday: {}, onPrevious: {}, onNext: {})
        .padding()
        .appBackground()
        .environment(\.colors, .dark)
}
