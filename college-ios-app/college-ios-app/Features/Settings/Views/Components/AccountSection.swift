//
//  AccountSection.swift
//  college-ios-app
//

import SwiftUI

struct AccountSection: View {
    @Environment(\.colors) private var colors
    @EnvironmentObject private var sessionViewModel: SessionViewModel

    let onLogin: () -> Void

    @State private var didApplyGroup = false

    var body: some View {
        SettingsSectionTitle("Аккаунт")
        SettingsCard {
            if let user = sessionViewModel.user {
                account(for: user)
            } else {
                signInRow
            }
        }
    }

    // MARK: - Rows

    private var signInRow: some View {
        Button(action: onLogin) {
            SettingsRow(icon: "person", title: "Войти") {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(colors.onSurfaceVariant)
                    .accessibilityHidden(true)
            }
        }
        .buttonStyle(SettingsRowButtonStyle())
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func account(for user: User) -> some View {
        SettingsRow(icon: "person", title: user.username) {
            Text(user.academicGroup ?? "")
                .textStyle(AppType.bodyMedium)
                .foregroundStyle(colors.onSurfaceVariant)
        }

        if let selection = SelectionMapping.selection(of: user) {
            SettingsDivider()
            applyGroupRow(selection)
        }

        SettingsDivider()

        Button {
            didApplyGroup = false
            sessionViewModel.signOut()
        } label: {
            SettingsRow(
                icon: "rectangle.portrait.and.arrow.right",
                title: "Выйти",
                tint: colors.danger
            ) {}
        }
        .buttonStyle(SettingsRowButtonStyle())
        .accessibilityElement(children: .combine)
    }

    private func applyGroupRow(_ selection: Selection) -> some View {
        Button {
            SelectionStore().save(selection)
            didApplyGroup = true
        } label: {
            SettingsRow(icon: "calendar", title: "Использовать мою группу") {
                if didApplyGroup {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primary)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(SettingsRowButtonStyle())
        .accessibilityElement(children: .combine)
    }
}
