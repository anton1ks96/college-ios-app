//
//  AboutView.swift
//  college-ios-app
//
//  Created by pc on 25.09.2025.
//

import SwiftUI
import Foundation

// MARK: - Helpers

private extension View {
    @ViewBuilder
    func compatButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.plain)
        }
    }
}

private var devButtonBackground: AnyShapeStyle {
    if #available(iOS 26.0, *) {
        AnyShapeStyle(.ultraThinMaterial)
    } else {
        AnyShapeStyle(Color.black.opacity(0.7))
    }
}

// MARK: - Reusable rows

struct AboutLinkRow: View {
    let title: String
    let systemImage: String
    let urlString: String

    var body: some View {
        Link(destination: URL(string: urlString)!) {
            HStack {
                Label(title, systemImage: systemImage)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TelegramLinkButton: View {
    let urlString: String
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Button {
            let url = URL(string: urlString)!
                openURL(url)
        } label: {
            Image("telegram")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(6)
                .background(Circle().fill(devButtonBackground))
                .overlay(Circle().stroke(.white.opacity(0.3)))
        }
        .compatButtonStyle()
    }
}

struct DevLinkButton: View {
    let urlString: String
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            let url = URL(string: urlString)!
                openURL(url)
        } label: {
            Image("github")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(6)
                .background(Circle().fill(devButtonBackground))
                .overlay(Circle().stroke(.white.opacity(0.3)))
        }
        .compatButtonStyle()
    }
}

// MARK: - App Info

private extension Bundle {
    var appName: String {
        if let display = infoDictionary?["CFBundleDisplayName"] as? String { return display }
        return infoDictionary?["CFBundleName"] as? String ?? "App"
    }

    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    var appBuild: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}

struct AboutHeaderView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(Bundle.main.appName) для iOS")
                    .font(.headline)

                Text("Версия \(Bundle.main.appVersion) (\(Bundle.main.appBuild))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("© 2021-2025 АНПОО \"Колледж Цифровых Технологий\"")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Учебное приложение для студентов колледжа цифровых технологий")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Screen

struct AboutView: View {
    var body: some View {
        Form {
            Section {
                AboutHeaderView()
            }
            
            Section("Действия") {
                AboutLinkRow(title: "Сообщить о проблеме",
                             systemImage: "ladybug",
                             urlString: "https://t.me/IKolomatskii")
                
                AboutLinkRow(title: "Исходный код",
                             systemImage: "chevron.left.forwardslash.chevron.right",
                             urlString: "https://github.com/anton1ks96/college-ios-app")
                
                AboutLinkRow(title: "Вебсайт",
                             systemImage: "network",
                             urlString: "https://it-college.ru")
            }
            
            Section("Разработчики") {
                LabeledContent {
                    HStack(spacing: 12) {
                        DevLinkButton(urlString: "https://github.com/anton1ks96")
                        TelegramLinkButton(urlString: "https://t.me/IKolomatskii")
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text("Иван Коломацкий")
                        Text("iOS разработчик")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                LabeledContent {
                    HStack(spacing: 12) {
                        DevLinkButton(urlString: "https://github.com/airsss993")
                        TelegramLinkButton(urlString: "https://t.me/airsss993")
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text("Артём Джапаридзе")
                        Text("Android разработчик")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Маркетинг") {
                LabeledContent {
                    HStack(spacing: 12) {
                        DevLinkButton(urlString: "https://github.com/necrasov-ilya")
                        TelegramLinkButton(urlString: "https://t.me/NKSV_ILYA")
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text("Илья Некрасов")
                        Text("Маркетолог")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("О приложении")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AboutView()
}
