//
//  DotGrid.swift
//  college-ios-app
//

import SwiftUI

struct DotGrid: View {
    @Environment(\.colors) private var colors

    var step: CGFloat = Metrics.dotGridStep
    var dot: CGFloat = Metrics.dotGridDot

    var body: some View {
        Canvas { context, size in
            var path = Path()
            var y = step / 2
            while y < size.height {
                var x = step / 2
                while x < size.width {
                    path.addEllipse(in: CGRect(x: x - dot, y: y - dot, width: dot * 2, height: dot * 2))
                    x += step
                }
                y += step
            }
            context.fill(path, with: .color(colors.onSurface.opacity(Metrics.dotGridOpacity)))
        }
        .allowsHitTesting(false)
    }
}
