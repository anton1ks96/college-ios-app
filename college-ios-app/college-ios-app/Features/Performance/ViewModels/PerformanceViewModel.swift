//
//  PerformanceViewModel.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class PerformanceViewModel: ObservableObject {
    @Published var subjects: [PerformanceSubject] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let api: PerformanceAPIProtocol
    private var didInitialLoad = false
    
    init(api: PerformanceAPIProtocol) {
        self.api = api
    }
    
    // MARK: - Lifecycle
    
    func onAppearOnce() {
        guard !didInitialLoad else { return }
        didInitialLoad = true
        Task {
            await loadSubjects()
        }
    }
    
    // MARK: - Data Loading
    
    func loadSubjects() async {
        isLoading = true
        errorMessage = nil
        
        do {
            subjects = try await api.fetchSubjects()
            isLoading = false
        } catch let error as APIError {
            isLoading = false
            errorMessage = error.errorDescription
        } catch {
            isLoading = false
            errorMessage = "Не удалось загрузить список предметов"
        }
    }
    
    func refresh() async {
        await loadSubjects()
    }

    func clear() {
        subjects = []
        errorMessage = nil
        didInitialLoad = false
    }

    // MARK: - Factory

    func makeSubjectDetailViewModel(for subject: PerformanceSubject) -> SubjectDetailViewModel {
        SubjectDetailViewModel(api: api, subject: subject)
    }
}
