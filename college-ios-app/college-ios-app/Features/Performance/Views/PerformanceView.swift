//
//  PerformanceView.swift
//  college-ios-app
//
//  Created by pc on 14.11.2025.
//

import SwiftUI

struct PerformanceView: View {
    @ObservedObject var viewModel: PerformanceViewModel
    
    var body: some View {
            VStack(spacing: 0) {
                if viewModel.isLoading && viewModel.subjects.isEmpty {
                    loadingView
                } else if let error = viewModel.errorMessage, viewModel.subjects.isEmpty {
                    errorView(message: error)
                } else if viewModel.subjects.isEmpty {
                    emptySubjectsMessage
                } else {
                    subjectsContent
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Успеваемость")
            .navigationBarTitleDisplayMode(.large)
            .streakToolbar()
            .accountToolbar()
            .task {
                viewModel.onAppearOnce()
            }
        }
    
    // MARK: - Content
    
    private var subjectsContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.subjects.isEmpty {
                    emptySubjectsMessage
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.subjects) { subject in
                            NavigationLink {
                                SubjectDetailView(
                                    viewModel: viewModel.makeSubjectDetailViewModel(for: subject)
                                )
                            } label: {
                                SubjectCard(subject: subject)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - States
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Загрузка предметов...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Ошибка загрузки")
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                Task { await viewModel.refresh() }
            } label: {
                Label("Повторить", systemImage: "arrow.clockwise")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptySubjectsMessage: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Нет данных об успеваемости")
                    .font(.headline)
                Text("Для выбранного периода данные по предметам отсутствуют")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview Helpers

private func createPreviewSessionViewModel() -> SessionViewModel {
    let refreshStorage = KeychainTokenStorage()
    let authSession = AuthSession(refreshStorage: refreshStorage)
    let decoder = JSONDecoder()
    let client = AFHTTPClient(baseURL: AppEnvironment.authBaseURL, decoder: decoder)
    let api = AuthAPI(client: client)
    let authService = AuthService(api: api, session: authSession)
    return SessionViewModel(authService: authService, authSession: authSession)
}

// MARK: - Mock API for Preview

private final class MockPerformanceAPI: PerformanceAPIProtocol {
    let shouldDelay: Bool
    let isEmpty: Bool
    let shouldFail: Bool
    let delay: TimeInterval
    
    init(
        shouldDelay: Bool = false,
        isEmpty: Bool = false,
        shouldFail: Bool = false,
        delay: TimeInterval = 1.0
    ) {
        self.shouldDelay = shouldDelay
        self.isEmpty = isEmpty
        self.shouldFail = shouldFail
        self.delay = delay
    }
    
    func fetchSubjects() async throws -> [PerformanceSubject] {
        if shouldDelay {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        if shouldFail {
            throw APIError.decodingFailed
        }
        if isEmpty {
            return []
        }
        return [
            PerformanceSubject(suIDcrc: "crc-101", suID: "SU-101", title: "Математика"),
            PerformanceSubject(suIDcrc: "crc-202", suID: "SU-202", title: "Информатика"),
            PerformanceSubject(suIDcrc: "crc-303", suID: "SU-303", title: "Физика"),
            PerformanceSubject(suIDcrc: "crc-404", suID: "SU-404", title: "История")
        ]
    }
    
    func fetchScores(suID: String, start: Date, end: Date) async throws -> [PerformanceLesson] {
        if shouldDelay {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        if shouldFail {
            throw APIError.decodingFailed
        }
        if isEmpty {
            return []
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        func d(_ str: String) -> String { str }
        
        let kontrol = PerformanceLesson(
            lessonName: "Контрольные",
            scores: [
                PerformanceScore(
                    dateF: d("2025-11-10"),
                    dateP: nil,
                    score: "5",
                    maxScore: 5,
                    description: "Контрольная работа №1"
                ),
                PerformanceScore(
                    dateF: d("2025-11-24"),
                    dateP: nil,
                    score: "4",
                    maxScore: 5,
                    description: "Контрольная работа №2"
                ),
                PerformanceScore(
                    dateF: nil,
                    dateP: d("2025-12-15"),
                    score: "",
                    maxScore: 5,
                    description: "Контрольная работа №3 (ожидается)"
                )
            ]
        )
        
        let practice = PerformanceLesson(
            lessonName: "Практика",
            scores: [
                PerformanceScore(
                    dateF: d("2025-10-05"),
                    dateP: nil,
                    score: "3",
                    maxScore: 5,
                    description: "Практическая работа: Массивы"
                ),
                PerformanceScore(
                    dateF: nil,
                    dateP: d("2025-12-01"),
                    score: "",
                    maxScore: 5,
                    description: "Практическая работа: Алгоритмы (ожидается)"
                ),
                PerformanceScore(
                    dateF: nil,
                    dateP: d("2025-12-20"),
                    score: "",
                    maxScore: 5,
                    description: "Практическая работа: Сортировки (ожидается)"
                )
            ]
        )
        
        let project = PerformanceLesson(
            lessonName: "Проект",
            scores: [
                PerformanceScore(
                    dateF: d("2025-11-01"),
                    dateP: nil,
                    score: "5",
                    maxScore: 5,
                    description: "Этап 1: Аналитика требований"
                ),
                PerformanceScore(
                    dateF: d("2025-11-18"),
                    dateP: nil,
                    score: "5",
                    maxScore: 5,
                    description: "Этап 2: Прототипирование"
                ),
                PerformanceScore(
                    dateF: nil,
                    dateP: d("2025-12-28"),
                    score: "",
                    maxScore: 5,
                    description: "Этап 3: Демонстрация (ожидается)"
                )
            ]
        )
        
        return [kontrol, practice, project]
    }
}

// MARK: - Previews: Список предметов

#Preview("Список - с данными") {
    let mockAPI = MockPerformanceAPI()
    let viewModel = PerformanceViewModel(api: mockAPI)
    
    NavigationStack {
        PerformanceView(viewModel: viewModel)
            .environmentObject(createPreviewSessionViewModel())
    }
    .task {
        await viewModel.loadSubjects()
    }
}

#Preview("Список - загрузка") {
    let mockAPI = MockPerformanceAPI(shouldDelay: true, isEmpty: false, shouldFail: false, delay: 3.0)
    let viewModel = PerformanceViewModel(api: mockAPI)
    
    NavigationStack {
        PerformanceView(viewModel: viewModel)
            .environmentObject(createPreviewSessionViewModel())
    }
    .task {
        await viewModel.loadSubjects()
    }
}

#Preview("Список - пусто") {
    let mockAPI = MockPerformanceAPI(isEmpty: true)
    let viewModel = PerformanceViewModel(api: mockAPI)
    
    NavigationStack {
        PerformanceView(viewModel: viewModel)
            .environmentObject(createPreviewSessionViewModel())
    }
    .task {
        await viewModel.loadSubjects()
    }
}

#Preview("Список - ошибка") {
    let mockAPI = MockPerformanceAPI(shouldFail: true)
    let viewModel = PerformanceViewModel(api: mockAPI)
    
    NavigationStack {
        PerformanceView(viewModel: viewModel)
            .environmentObject(createPreviewSessionViewModel())
    }
    .task {
        await viewModel.loadSubjects()
    }
}

// MARK: - Previews: Детальный экран предмета

#Preview("Предмет - с оценками") {
    let mockAPI = MockPerformanceAPI()
    let subject = PerformanceSubject(suIDcrc: "crc-202", suID: "SU-202", title: "Информатика")
    let vm = SubjectDetailViewModel(api: mockAPI, subject: subject)
    
    NavigationStack {
        SubjectDetailView(viewModel: vm)
            .environmentObject(createPreviewSessionViewModel())
    }
    .task {
        await vm.loadScores()
    }
}

#Preview("Предмет - загрузка") {
    let mockAPI = MockPerformanceAPI(shouldDelay: true, isEmpty: false, shouldFail: false, delay: 3.0)
    let subject = PerformanceSubject(suIDcrc: "crc-101", suID: "SU-101", title: "Математика")
    let vm = SubjectDetailViewModel(api: mockAPI, subject: subject)
    
    NavigationStack {
        SubjectDetailView(viewModel: vm)
            .environmentObject(createPreviewSessionViewModel())
    }
    .task {
        await vm.loadScores()
    }
}

#Preview("Предмет — пусто") {
    let mockAPI = MockPerformanceAPI(isEmpty: true)
    let subject = PerformanceSubject(suIDcrc: "crc-404", suID: "SU-404", title: "История")
    let vm = SubjectDetailViewModel(api: mockAPI, subject: subject)
    
    NavigationStack {
        SubjectDetailView(viewModel: vm)
            .environmentObject(createPreviewSessionViewModel())
    }
    .task {
        await vm.loadScores()
    }
}
