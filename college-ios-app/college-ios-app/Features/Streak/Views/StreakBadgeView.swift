//
//  StreakBadgeView.swift
//  college-ios-app
//  Created by pc on 24.11.2025.
//

import SwiftUI

struct StreakBadgeView: View {
    let count: Int
    var increase: Int = 1
    var isLoading: Bool = false
    
    @State private var displayedCount: Int
    @State private var showPlusOne: Bool = false
    @State private var textPopScale: CGFloat = 1.0
    @State private var containerWidth: CGFloat = 75
    
    private let baseWidth: CGFloat = 75
    private let expandedWidth: CGFloat = 100
    
    init(count: Int, increase: Int = 1, isLoading: Bool = false) {
        self.count = count
        self.increase = increase
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
                
                if showPlusOne && increase > 0 {
                    Text("+\(increase)")
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
            if newValue > oldValue && increase > 0 {
                animateSequence(newValue: newValue)
            } else {
                displayedCount = newValue
            }
        }
    }
    
    private func animateSequence(newValue: Int) {
        expandWidth {
            showPlusOne = true
            textPopScale = 1.1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { textPopScale = 1.0 }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showPlusOne = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    displayedCount = newValue
                    textPopScale = 1.2
                    
                    shrinkWidth {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { textPopScale = 1.0 }
                    }
                }
            }
        }
    }
    
    private func expandWidth(completion: @escaping () -> Void) {
        let steps = Int(expandedWidth - baseWidth)
        let interval: TimeInterval = 0.01
        
        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                containerWidth = baseWidth + CGFloat(i + 1)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(steps)) {
            completion()
        }
    }
    
    private func shrinkWidth(completion: @escaping () -> Void) {
        let steps = Int(expandedWidth - baseWidth)
        let interval: TimeInterval = 0.01
        
        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                containerWidth = expandedWidth - CGFloat(i + 1)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(steps)) {
            completion()
        }
    }
}

// MARK: - Static States Preview

#Preview("Все состояния") {
    VStack(spacing: 24) {
        Text("Статические состояния")
            .font(.headline)
        
        HStack(spacing: 20) {
            VStack {
                StreakBadgeView(count: 0)
                Text("Пустой")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack {
                StreakBadgeView(count: 15)
                Text("Активный")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack {
                StreakBadgeView(count: 0, isLoading: true)
                Text("Загрузка")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        
        Divider()
        
        Text("С анимацией прибавки")
            .font(.headline)
        
        HStack(spacing: 20) {
            VStack {
                StreakBadgeView(count: 5, increase: 1)
                Text("+1 день")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack {
                StreakBadgeView(count: 10, increase: 5)
                Text("+5 дней")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack {
                StreakBadgeView(count: 15, increase: 15)
                Text("Первый запуск")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    .padding()
}

// MARK: - Interactive Animation Preview

struct StreakAnimationPreview: View {
    @State private var count = 5
    @State private var selectedIncrease = 1
    
    private let increaseOptions = [1, 3, 5, 10]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                Text("Текущий streak: \(count)")
                    .font(.title2)
                
                Picker("Прибавка", selection: $selectedIncrease) {
                    ForEach(increaseOptions, id: \.self) { value in
                        Text("+\(value)").tag(value)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Button("Добавить \(selectedIncrease) дней") {
                    count += selectedIncrease
                }
                .buttonStyle(.borderedProminent)
                
                Button("Сбросить") {
                    count = 5
                }
                .foregroundStyle(.secondary)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        
                        StreakBadgeView(count: count, increase: selectedIncrease)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Анимация")
                        .bold()
                }
            }
        }
    }
}

#Preview("Интерактивная анимация") {
    StreakAnimationPreview()
}

// MARK: - First Launch Simulation

struct StreakFirstLaunchPreview: View {
    @State private var count = 0
    @State private var hasLoaded = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Text("Симуляция первого запуска")
                    .font(.headline)
                
                Text("Студент ходил 15 дней,\nно приложение открыл впервые")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                Button("Загрузить streak") {
                    hasLoaded = true
                    count = 15
                }
                .buttonStyle(.borderedProminent)
                .disabled(hasLoaded)
                
                Button("Сбросить") {
                    hasLoaded = false
                    count = 0
                }
                .foregroundStyle(.secondary)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        
                        StreakBadgeView(
                            count: count,
                            increase: hasLoaded ? 15 : 0
                        )
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Первый запуск")
                        .bold()
                }
            }
        }
    }
}

#Preview("Первый запуск (+15)") {
    StreakFirstLaunchPreview()
}

// MARK: - Week Missed Simulation

struct StreakWeekMissedPreview: View {
    @State private var count = 10
    @State private var hasUpdated = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Text("Симуляция пропущенной недели")
                    .font(.headline)
                
                Text("Студент не заходил в приложение\nвсю неделю (Пн-Пт), но посещал колледж")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                Button("Обновить streak (+5 дней)") {
                    hasUpdated = true
                    count = 15
                }
                .buttonStyle(.borderedProminent)
                .disabled(hasUpdated)
                
                Button("Сбросить") {
                    hasUpdated = false
                    count = 10
                }
                .foregroundStyle(.secondary)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        
                        StreakBadgeView(
                            count: count,
                            increase: hasUpdated ? 5 : 0
                        )
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Пн-Пт без приложения")
                        .bold()
                }
            }
        }
    }
}

#Preview("Неделя без приложения (+5)") {
    StreakWeekMissedPreview()
}
