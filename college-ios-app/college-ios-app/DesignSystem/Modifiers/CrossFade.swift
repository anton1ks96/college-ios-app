//
//  CrossFade.swift
//  college-ios-app
//

import SwiftUI

extension AnyTransition {
    static func crossFade(out: Double, in insertion: Double) -> AnyTransition {
        .asymmetric(
            insertion: .opacity.animation(.easeInOut(duration: insertion).delay(out)),
            removal: .opacity.animation(.easeInOut(duration: out))
        )
    }
}
