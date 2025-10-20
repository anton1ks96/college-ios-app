//
//  SplashView.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        GeometryReader { geometry in
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Image("LaunchIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                Text("МойКЦТ")
                    .font(.system(size: 36, weight: .semibold))
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SplashView()
}
