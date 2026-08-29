//
//  WelcomeScreen.swift
//  college-ios-app
//

import SwiftUI

private let logoSide: CGFloat = 84
private let logoRadius: CGFloat = 26

struct WelcomeScreen: View {
    @Environment(\.colors) private var colors

    let onEnter: () -> Void

    @State private var isLoginPresented = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            logo

            Text("Добро пожаловать в МойКЦТ")
                .textStyle(AppType.heroValue)
                .foregroundStyle(colors.onBackground)
                .multilineTextAlignment(.center)
                .padding(.top, 28)

            Text("Расписание, посещаемость и баллы — всё в одном приложении.")
                .textStyle(AppType.bodyLarge)
                .foregroundStyle(colors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.top, 12)

            Button {
                isLoginPresented = true
            } label: {
                Text("Войти")
                    .textStyle(AppType.titleMedium)
            }
            .accentAction()
            .padding(.top, 32)

            Button(action: onEnter) {
                Text("Нет аккаунта? ")
                    .foregroundStyle(colors.onSurfaceVariant)
                    + Text("Продолжить без входа")
                    .foregroundStyle(colors.onBackground)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.plain)
            .textStyle(AppType.bodyLarge)
            .multilineTextAlignment(.center)
            .padding(.top, 20)

            Text("Расписание доступно без входа. Вход нужен для посещаемости и баллов.")
                .textStyle(AppType.bodySmall)
                .foregroundStyle(colors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackground()
        .fullScreenCover(isPresented: $isLoginPresented) {
            LoginScreen(
                onClose: { isLoginPresented = false },
                onSkip: onEnter
            )
        }
    }

    // MARK: - Parts

    private var logo: some View {
        Image("LaunchIcon")
            .resizable()
            .scaledToFit()
            .frame(width: logoSide, height: logoSide)
            .padding(10)
            .glassSurface(RoundedRectangle(cornerRadius: logoRadius, style: .continuous))
            .shadow(color: colors.primary.opacity(colors.isDark ? 0.45 : 0.25), radius: 40)
            .accessibilityHidden(true)
    }
}

#Preview("Тёмная") {
    WelcomeScreen(onEnter: {})
        .environment(\.colors, .dark)
}

#Preview("Светлая") {
    WelcomeScreen(onEnter: {})
        .environment(\.colors, .light)
}
