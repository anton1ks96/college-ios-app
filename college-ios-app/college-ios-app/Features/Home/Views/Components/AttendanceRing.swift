//
//  AttendanceRing.swift
//  college-ios-app
//

import SwiftUI

private let ringSize: CGFloat = 216
private let tickLength: CGFloat = 16
private let ringRadius: CGFloat = 28

struct AttendanceRing: View {
    @Environment(\.colors) private var colors

    let weekTitle: String
    let stats: AttendanceStats
    let value: String
    let caption: String
    let hasData: Bool

    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: 12) {
            Text(weekTitle)
                .textStyle(AppType.labelLarge)
                .foregroundStyle(colors.onSurfaceVariant)

            ZStack {
                ticks(lineWidth: 5, isGlow: true)
                    .blur(radius: 10)
                    .opacity(0.7)

                ticks(lineWidth: 4, isGlow: false)

                center
            }
            .frame(width: ringSize, height: ringSize)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .glassSurface(RoundedRectangle(cornerRadius: ringRadius, style: .continuous))
        .onChange(of: stats, initial: true) { _, _ in animate() }
        .onChange(of: hasData) { _, _ in animate() }
        .accessibilityElement(children: .combine)
    }

    private func ticks(lineWidth: CGFloat, isGlow: Bool) -> some View {
        RingTicks(
            progress: progress,
            bounds: RingScale.bounds(for: stats),
            palette: RingPalette(
                track: colors.onSurface.opacity(0.12),
                present: colors.success,
                excused: colors.warning,
                absent: colors.danger
            ),
            lineWidth: lineWidth,
            isGlow: isGlow
        )
    }

    private var center: some View {
        VStack(spacing: 2) {
            Text(value)
                .textStyle(hasData ? AppType.displayMedium : AppType.titleLarge)
                .foregroundStyle(colors.onBackground)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            if !caption.isEmpty {
                Text(caption)
                    .textStyle(AppType.bodyMedium)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 44)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    private func animate() {
        withAnimation(.easeInOut(duration: 0.7)) {
            progress = hasData ? 1 : 0
        }
    }
}

private struct RingPalette: Equatable {
    let track: Color
    let present: Color
    let excused: Color
    let absent: Color
}

private struct RingTicks: View, Animatable {
    var progress: Double
    let bounds: RingScale.Bounds
    let palette: RingPalette
    let lineWidth: CGFloat
    let isGlow: Bool

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        Canvas { context, size in
            let shown = Int((Double(RingScale.tickCount) * progress).rounded())
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outer = min(size.width, size.height) / 2 - lineWidth / 2
            let step = 360.0 / Double(RingScale.tickCount)

            for index in 0..<RingScale.tickCount {
                guard let color = color(at: index, shown: shown) else { continue }

                let angle = (-90 + step * Double(index)) * .pi / 180
                let dx = cos(angle)
                let dy = sin(angle)

                var path = Path()
                path.move(
                    to: CGPoint(
                        x: center.x + dx * (outer - tickLength),
                        y: center.y + dy * (outer - tickLength)
                    )
                )
                path.addLine(to: CGPoint(x: center.x + dx * outer, y: center.y + dy * outer))

                context.stroke(
                    path,
                    with: .color(color),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            }
        }
    }

    private func color(at index: Int, shown: Int) -> Color? {
        guard index < shown else { return isGlow ? nil : palette.track }
        if index < bounds.present { return palette.present }
        if index < bounds.excused { return palette.excused }
        if index < bounds.absent { return palette.absent }
        return isGlow ? nil : palette.track
    }
}

#Preview {
    VStack(spacing: 20) {
        AttendanceRing(
            weekTitle: "Неделя 24 – 30 августа",
            stats: AttendanceStats(total: 16, present: 12, absent: 2, excused: 2),
            value: "75%",
            caption: "Был на 12 из 16 пар",
            hasData: true
        )

        AttendanceRing(
            weekTitle: "Неделя 17 – 23 августа",
            stats: .empty,
            value: "Отметок нет",
            caption: "",
            hasData: false
        )
    }
    .padding(20)
    .appBackground()
    .environment(\.colors, .dark)
}
