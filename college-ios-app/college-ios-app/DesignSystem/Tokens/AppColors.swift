//
//  AppColors.swift
//  college-ios-app
//

import SwiftUI

struct AppColors: Equatable, Sendable {
    let primary: Color
    let onPrimary: Color
    let primaryContainer: Color
    let onPrimaryContainer: Color
    let secondary: Color
    let onSecondary: Color
    let tertiary: Color
    let onTertiary: Color
    let background: Color
    let onBackground: Color
    let surface: Color
    let onSurface: Color
    let surfaceVariant: Color
    let onSurfaceVariant: Color
    let outlineVariant: Color
    let isDark: Bool

    static let light = AppColors(
        primary: .violet,
        onPrimary: .white,
        primaryContainer: .violetSoft,
        onPrimaryContainer: .ink,
        secondary: .statusGreen,
        onSecondary: .white,
        tertiary: .violet,
        onTertiary: .white,
        background: .lightBackground,
        onBackground: .ink,
        surface: .white,
        onSurface: .ink,
        surfaceVariant: .greyFill,
        onSurfaceVariant: .greyText,
        outlineVariant: .greyFill,
        isDark: false
    )

    static let dark = AppColors(
        primary: .violet,
        onPrimary: .white,
        primaryContainer: .violetDeep,
        onPrimaryContainer: .white,
        secondary: .statusGreen,
        onSecondary: .white,
        tertiary: .violet,
        onTertiary: .white,
        background: .darkBackground,
        onBackground: .white,
        surface: .darkSurface,
        onSurface: .white,
        surfaceVariant: .darkGreyFill,
        onSurfaceVariant: .darkGreyText,
        outlineVariant: .darkGreyFill,
        isDark: true
    )

    static func of(_ scheme: ColorScheme) -> AppColors {
        scheme == .dark ? .dark : .light
    }
}
