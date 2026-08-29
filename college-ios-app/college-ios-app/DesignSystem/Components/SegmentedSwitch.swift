//
//  SegmentedSwitch.swift
//  college-ios-app
//

import SwiftUI

struct SegmentedSwitch<Value: Hashable>: View {
    @Environment(\.colors) private var colors
    @Namespace private var glass

    let items: [Value]
    let title: (Value) -> String
    @Binding var selection: Value

    var body: some View {
        GlassGroup(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(items, id: \.self) { item in
                    segment(item)
                }
            }
        }
        .animation(.snappy(duration: 0.28), value: selection)
    }

    @ViewBuilder
    private func segment(_ item: Value) -> some View {
        let isSelected = item == selection

        Button {
            selection = item
        } label: {
            Text(title(item))
                .textStyle(AppType.labelLarge)
                .foregroundStyle(isSelected ? colors.onTertiary : colors.onSurfaceVariant)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .modifier(SegmentSurface(isSelected: isSelected, namespace: glass))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

private struct SegmentSurface: ViewModifier {
    @Environment(\.colors) private var colors

    let isSelected: Bool
    let namespace: Namespace.ID

    @ViewBuilder
    func body(content: Content) -> some View {
        if isSelected {
            content
                .glassSurface(Capsule(), tint: colors.primary, interactive: true)
                .glassMorph(id: "segment", in: namespace)
        } else {
            content
        }
    }
}

#Preview {
    @Previewable @State var selection = "Посещаемость"

    return SegmentedSwitch(
        items: ["Посещаемость", "Успеваемость"],
        title: { $0 },
        selection: $selection
    )
    .padding(20)
    .appBackground()
    .environment(\.colors, .dark)
}
