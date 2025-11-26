//
//  StreakBadgeView.swift
//  college-ios-app
//  Created by pc on 24.11.2025.
//

import SwiftUI

struct StreakBadgeView: View {
    let count: Int
    var isLoading: Bool = false
    
    @State private var displayedCount: Int
    @State private var showPlusOne: Bool = false
    @State private var textPopScale: CGFloat = 1.0
    
    private let containerWidth: CGFloat = 75
    
    init(count: Int, isLoading: Bool = false) {
        self.count = count
        self.isLoading = isLoading
        _displayedCount = State(initialValue: count)
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            if isLoading {
                ProgressView().scaleEffect(0.7)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(
                            LinearGradient(
                                colors: displayedCount > 0 ? [.orange, .red] : [.gray, .gray.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("\(displayedCount)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(displayedCount > 0 ? .orange : .gray)
                        .contentTransition(.numericText(value: Double(displayedCount)))
                }
                .offset(x: showPlusOne ? -10 : 0)
                .scaleEffect(textPopScale)
                
                if showPlusOne {
                    Text("+1")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .offset(x: 24)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.5)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                }
            }
        }
        .frame(width: containerWidth, height: 32)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showPlusOne)
        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: textPopScale)
        .animation(.default, value: displayedCount)
        
        .onChange(of: count) { oldValue, newValue in
            if newValue > oldValue {
                animateSequence(newValue: newValue)
            } else {
                displayedCount = newValue
            }
        }
    }
    
    private func animateSequence(newValue: Int) {
        showPlusOne = true
        textPopScale = 1.1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { textPopScale = 1.0 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showPlusOne = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                displayedCount = newValue
                textPopScale = 1.2
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { textPopScale = 1.0 }
            }
        }
    }
}

struct StreakCenterPreview: View {
    @State private var count = 5
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Посмотрите на Toolbar сверху")
                    .foregroundStyle(.secondary)
                Button("Добавить день") {
                    count += 1
                }
                .buttonStyle(.borderedProminent)
                .padding()
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    StreakBadgeView(count: count)
                        .background(Capsule().fill(Color.gray.opacity(0.1)))
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Главная")
                        .bold()
                }
            }
        }
    }
}

#Preview {
    StreakCenterPreview()
}
