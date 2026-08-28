//
//  AmbientGlow.swift
//  college-ios-app
//

import SwiftUI

struct AmbientGlow: View {
    @Environment(\.colors) private var colors

    var body: some View {
        Canvas { context, size in
            let width = size.width
            let strength = colors.isDark ? 1.0 : 0.5

            glow(
                in: context, color: colors.primary, opacity: 0.50 * strength,
                center: CGPoint(x: width * 0.42, y: -width * 0.05), radius: width * 0.80
            )
            glow(
                in: context, color: .violetMagenta, opacity: 0.30 * strength,
                center: CGPoint(x: width, y: width * 0.12), radius: width * 0.55
            )
            if colors.isDark {
                glow(
                    in: context, color: .violetIndigo, opacity: 0.35,
                    center: CGPoint(x: width * 0.12, y: size.height), radius: width * 0.55
                )
            } else {
                glow(
                    in: context, color: colors.primary, opacity: 0.30 * strength,
                    center: CGPoint(x: width * 0.12, y: size.height), radius: width * 0.60
                )
            }
        }
        .allowsHitTesting(false)
    }

    private func glow(
        in context: GraphicsContext,
        color: Color,
        opacity: Double,
        center: CGPoint,
        radius: CGFloat
    ) {
        let rect = CGRect(
            x: center.x - radius, y: center.y - radius,
            width: radius * 2, height: radius * 2
        )
        context.fill(
            Path(ellipseIn: rect),
            with: .radialGradient(
                Gradient(colors: [color.opacity(opacity), color.opacity(0)]),
                center: center,
                startRadius: 0,
                endRadius: radius
            )
        )
    }
}
