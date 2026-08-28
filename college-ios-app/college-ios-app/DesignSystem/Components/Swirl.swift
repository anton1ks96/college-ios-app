//
//  Swirl.swift
//  college-ios-app
//

import SwiftUI

struct Swirl: View {
    @Environment(\.colors) private var colors

    var color: Color?
    var duration: Double = 1.5

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let raw = triangle(time / duration)
                let dash = raw * raw * (3 - 2 * raw)
                let spin = time.truncatingRemainder(dividingBy: duration * 4 / 3) / (duration * 4 / 3) * 360

                let diameter = min(size.width, size.height)
                let stroke = diameter * 0.125
                let box = diameter - stroke
                let rect = CGRect(
                    x: (size.width - box) / 2,
                    y: (size.height - box) / 2,
                    width: box,
                    height: box
                )

                let start = dash < 0.5 ? 114.6 * dash : 57.3 + 343.8 * (dash - 0.5)
                let sweep = 0.3 + dash * 229

                var path = Path()
                path.addArc(
                    center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: box / 2,
                    startAngle: .degrees(spin + start),
                    endAngle: .degrees(spin + start + sweep),
                    clockwise: false
                )
                context.stroke(
                    path,
                    with: .color(color ?? colors.primary),
                    style: StrokeStyle(lineWidth: stroke, lineCap: .round)
                )
            }
        }
        .frame(minWidth: 40, minHeight: 40)
    }

    private func triangle(_ value: Double) -> Double {
        let phase = value.truncatingRemainder(dividingBy: 2)
        return phase < 1 ? phase : 2 - phase
    }
}

#Preview {
    Swirl().frame(width: 40, height: 40)
}
