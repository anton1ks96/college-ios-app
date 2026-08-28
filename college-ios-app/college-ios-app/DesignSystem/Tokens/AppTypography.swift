//
//  AppTypography.swift
//  college-ios-app
//

import SwiftUI
import UIKit

enum OnestWeight: String {
    case regular = "Onest-Regular"
    case semibold = "Onest-SemiBold"
    case bold = "Onest-Bold"
}

struct AppTextStyle {
    let font: Font
    let tracking: CGFloat
    let lineSpacing: CGFloat
}

enum AppType {
    static let headlineMedium = style(.bold, 24, lineHeight: 30, tracking: -0.5, relativeTo: .title2)
    static let headlineSmall = style(.bold, 22, lineHeight: 28, tracking: -0.4, relativeTo: .title2)
    static let titleLarge = style(.bold, 20, lineHeight: 26, tracking: -0.3, relativeTo: .title3)
    static let titleMedium = style(.semibold, 17, lineHeight: 22, tracking: -0.2, relativeTo: .headline)
    static let bodyLarge = style(.regular, 15, lineHeight: 21, tracking: 0, relativeTo: .subheadline)
    static let bodyMedium = style(.regular, 13, lineHeight: 18, tracking: 0, relativeTo: .footnote)
    static let bodySmall = style(.regular, 12, lineHeight: 16, tracking: 0, relativeTo: .caption)
    static let labelLarge = style(.semibold, 13, lineHeight: 16, tracking: 0, relativeTo: .footnote)
    static let labelMedium = style(.regular, 12, lineHeight: 15, tracking: 0, relativeTo: .caption)
    static let labelSmall = style(.regular, 11, lineHeight: 14, tracking: 0, relativeTo: .caption2)

    static func style(
        _ weight: OnestWeight,
        _ size: CGFloat,
        lineHeight: CGFloat,
        tracking: CGFloat,
        relativeTo textStyle: Font.TextStyle
    ) -> AppTextStyle {
        let intrinsic = UIFont(name: weight.rawValue, size: size)?.lineHeight ?? size * 1.2
        return AppTextStyle(
            font: .custom(weight.rawValue, size: size, relativeTo: textStyle),
            tracking: tracking,
            lineSpacing: max(0, lineHeight - intrinsic)
        )
    }
}

extension View {
    func textStyle(_ style: AppTextStyle) -> some View {
        font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
    }
}
