//
//  Glass.swift
//  college-ios-app
//

import SwiftUI

enum GlassStyle {
    case regular
    case clear
}

enum GlassSupport {
    static var isAvailable: Bool {
        if #available(iOS 26, *) { true } else { false }
    }
}

private struct GlassSurface<S: InsettableShape>: ViewModifier {
    @Environment(\.colors) private var colors

    let shape: S
    let style: GlassStyle
    let tint: Color?
    let interactive: Bool

    @available(iOS 26, *)
    private var glass: Glass {
        var glass: Glass = style == .clear ? .clear : .regular
        if let tint {
            glass = glass.tint(tint)
        }
        if interactive {
            glass = glass.interactive()
        }
        return glass
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.glassEffect(glass, in: shape)
        } else {
            content
                .background(colors.surfaceVariant, in: shape)
                .hairline(shape)
        }
    }
}

private struct GlassAction: ViewModifier {
    let tint: Color

    @ViewBuilder
    private func styled(_ content: Content) -> some View {
        if #available(iOS 26, *) {
            content.buttonStyle(.glassProminent)
        } else {
            content.buttonStyle(.borderedProminent)
        }
    }

    func body(content: Content) -> some View {
        styled(content)
            .tint(tint)
            .controlSize(.large)
            .buttonBorderShape(.capsule)
    }
}

struct GlassGroup<Content: View>: View {
    var spacing: CGFloat? = 0
    @ViewBuilder var content: () -> Content

    var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: spacing) { content() }
        } else {
            content()
        }
    }
}

extension View {
    func glassSurface<S: InsettableShape>(
        _ shape: S,
        style: GlassStyle = .regular,
        tint: Color? = nil,
        interactive: Bool = false
    ) -> some View {
        modifier(GlassSurface(shape: shape, style: style, tint: tint, interactive: interactive))
    }

    func glassSurface(
        style: GlassStyle = .regular,
        tint: Color? = nil,
        interactive: Bool = false
    ) -> some View {
        glassSurface(
            RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous),
            style: style,
            tint: tint,
            interactive: interactive
        )
    }

    func glassAction(tint: Color = .violet) -> some View {
        modifier(GlassAction(tint: tint))
    }
}
