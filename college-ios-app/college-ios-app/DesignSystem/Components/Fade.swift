//
//  Fade.swift
//  college-ios-app
//

import SwiftUI

enum Phase: Hashable {
    case loading
    case error
    case empty
    case content
}

func phaseOf(isLoading: Bool, error: String?, isEmpty: Bool = false) -> Phase {
    if isLoading { return .loading }
    if error != nil { return .error }
    if isEmpty { return .empty }
    return .content
}

struct Fade<Value: Hashable, Content: View>: View {
    let value: Value
    @ViewBuilder let content: (Value) -> Content

    var body: some View {
        ZStack(alignment: .top) {
            content(value)
                .id(value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.crossFade(out: 0.09, in: 0.22))
        }
        .animation(.default, value: value)
    }
}
