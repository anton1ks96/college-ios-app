//
//  ThemeEnvironment.swift
//  college-ios-app
//

import SwiftUI

private struct AppColorsKey: EnvironmentKey {
    static let defaultValue = AppColors.dark
}

extension EnvironmentValues {
    var colors: AppColors {
        get { self[AppColorsKey.self] }
        set { self[AppColorsKey.self] = newValue }
    }
}
