//
//  StreakViewModel.swift
//  college-ios-app
//
//  Created by pc on 24.11.2025.
//

import Foundation
internal import Combine

@MainActor
final class StreakViewModel: ObservableObject {
    @Published private(set) var streak: StreakResponse?
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let api: StreakAPIProtocol
    
    init(api: StreakAPIProtocol) {
        self.api = api
    }
    
    func loadStreak() async {
        isLoading = true
        errorMessage = nil
        
        do {
            streak = try await api.fetchStreak()
            isLoading = false
        } catch let error as APIError {
            isLoading = false
            errorMessage = error.errorDescription
        } catch {
            isLoading = false
            errorMessage = "Не удалось загрузить данные о streak"
        }
    }
    
    func refresh() async {
        await loadStreak()
    }
    
    func clear() {
        streak = nil
        errorMessage = nil
    }
}
