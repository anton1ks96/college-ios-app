//
//  Hairline.swift
//  college-ios-app
//

import SwiftUI

private struct Hairline<S: InsettableShape>: ViewModifier {
    @Environment(\.colors) private var colors

    let shape: S

    func body(content: Content) -> some View {
        content.overlay(
            shape.strokeBorder(
                colors.onSurface.opacity(Metrics.hairlineOpacity),
                lineWidth: 1
            )
        )
    }
}

extension View {
    func hairline<S: InsettableShape>(_ shape: S) -> some View {
        modifier(Hairline(shape: shape))
    }

    func hairline() -> some View {
        hairline(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
    }
}
