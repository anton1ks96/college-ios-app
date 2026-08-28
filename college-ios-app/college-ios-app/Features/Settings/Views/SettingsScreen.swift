//
//  SettingsScreen.swift
//  college-ios-app
//

import SwiftUI

struct SettingsScreen: View {
    @Environment(\.colors) private var colors
    @AppStorage("selectedTheme") private var theme: AppTheme = .system

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SettingsSectionTitle("Тема")
                SettingsCard {
                    ForEach(Array(AppTheme.allCases.enumerated()), id: \.element.id) { index, mode in
                        if index > 0 {
                            SettingsDivider()
                        }
                        themeRow(mode)
                    }
                }

                SettingsSectionTitle("О приложении")
                SettingsCard {
                    about
                }

                SettingsSectionTitle("Действия")
                SettingsCard {
                    SettingsLinkRow(
                        icon: "chevron.left.forwardslash.chevron.right",
                        title: "Исходный код",
                        url: URL(string: "https://github.com/anton1ks96/mykct-ios-app")!
                    )
                    SettingsDivider()
                    SettingsLinkRow(
                        icon: "globe",
                        title: "Веб-сайт",
                        url: URL(string: "https://it-college.ru/")!
                    )
                }

                SettingsSectionTitle("Команда")
                VStack(spacing: 12) {
                    ForEach(TeamMember.team) { member in
                        PersonCard(member: member)
                    }
                }
                .padding(.top, 6)

                Link(destination: URL(string: "https://t.me/IKolomatskii")!) {
                    Label("Написать разработчику", systemImage: "paperplane")
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .frame(maxWidth: .infinity)
                }
                .glassAction()
                .padding(.top, 28)
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 24)
        }
        .appBackground()
        .navigationTitle("Настройки")
    }

    private func themeRow(_ mode: AppTheme) -> some View {
        Button {
            theme = mode
        } label: {
            SettingsRow(icon: mode.icon, title: mode.rawValue) {
                if theme == mode {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primary)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(SettingsRowButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(theme == mode ? .isSelected : [])
    }

    private var about: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("МойКЦТ для iOS")
                .textStyle(AppType.titleMedium)
                .foregroundStyle(colors.onSurface)

            Text("Версия \(Bundle.main.appVersion)")
                .textStyle(AppType.bodyMedium)
                .foregroundStyle(colors.onSurfaceVariant)
                .padding(.top, 4)

            Text("© 2021–2026 АНПОО «Колледж Цифровых Технологий»")
                .textStyle(AppType.bodySmall)
                .foregroundStyle(colors.onSurfaceVariant)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
}

private extension AppTheme {
    var icon: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}

private extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
