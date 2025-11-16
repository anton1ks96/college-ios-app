//
//  AttendanceView.swift
//  college-ios-app
//
//  Created by pc on 14.11.2025.
//

import SwiftUI

struct AttendanceView: View {
    @ObservedObject var viewModel: AttendanceViewModel
    @State private var showInfoAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.records.isEmpty {
                loadingView
            } else if let error = viewModel.errorMessage, viewModel.records.isEmpty {
                errorView(message: error)
            } else {
                attendanceContent
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Посещаемость")
        .navigationBarTitleDisplayMode(.large)
        .accountToolbar()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showInfoAlert = true
                } label: {
                    Image(systemName: "info.circle")
                        .imageScale(.medium)
                }
            }
        }
        .alert("Информация", isPresented: $showInfoAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Причины отсутствия могут быть изменены после предоставления соответствующих документов в Учебную часть")
        }
        .task {
            viewModel.onAppearOnce()
        }
    }
    
    private var attendanceContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                WeekStatisticsCard(viewModel: viewModel)
                
                if viewModel.records.isEmpty {
                    emptyWeekMessage
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.groupedRecords, id: \.day) { group in
                            DayAttendanceCard(
                                day: group.records.first?.formattedDayHeader ?? group.day,
                                records: group.records
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyWeekMessage: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Нет занятий")
                    .font(.headline)
                Text("На выбранную неделю данные о посещаемости не найдены")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 40)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Загрузка посещаемости...")
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
                Task {
                    await viewModel.refresh()
                }
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

#Preview("С данными") {
    let mockAPI = MockAttendanceAPI()
    let viewModel = AttendanceViewModel(api: mockAPI)
    
    NavigationStack {
        AttendanceView(viewModel: viewModel)
            .environmentObject(createPreviewSessionViewModel())
    }
    .task {
        await viewModel.loadCurrentWeekAttendance()
    }
}

#Preview("Загрузка") {
    let mockAPI = MockAttendanceAPI(shouldLoad: true)
    let viewModel = AttendanceViewModel(api: mockAPI)
    
    NavigationStack {
        AttendanceView(viewModel: viewModel)
            .environmentObject(createPreviewSessionViewModel())
    }
    .task {
        await viewModel.loadCurrentWeekAttendance()
    }
}

#Preview("Пустое состояние") {
    let mockAPI = MockAttendanceAPI(isEmpty: true)
    let viewModel = AttendanceViewModel(api: mockAPI)
    
    NavigationStack {
        AttendanceView(viewModel: viewModel)
            .environmentObject(createPreviewSessionViewModel())
    }
    .task {
        await viewModel.loadCurrentWeekAttendance()
    }
}

// MARK: - Mock API для Preview

private class MockAttendanceAPI: AttendanceAPIProtocol {
    let shouldLoad: Bool
    let isEmpty: Bool
    
    init(shouldLoad: Bool = false, isEmpty: Bool = false) {
        self.shouldLoad = shouldLoad
        self.isEmpty = isEmpty
    }
    
    func fetchAttendance(start: Date, end: Date) async throws -> [AttendanceRecord] {
        if shouldLoad {
            try? await Task.sleep(nanoseconds: 10_000_000_000)
        }
        
        if isEmpty {
            return []
        }
        
        return [
            AttendanceRecord(
                clID: 2450,
                day: "2025-11-05",
                topic: "Контрольная 1",
                start: "2025-11-05 09:00",
                end: "2025-11-05 10:30",
                room: "3-3",
                status: 2,
                title: "Операционные системы и среды",
                color: "green",
                type: "2"
            ),
            AttendanceRecord(
                clID: 2452,
                day: "2025-11-05",
                topic: nil,
                start: "2025-11-05 13:00",
                end: "2025-11-05 14:30",
                room: "404",
                status: 2,
                title: "Иностранный язык в профессиональной деятельности",
                color: "green",
                type: "2"
            ),
            AttendanceRecord(
                clID: 2455,
                day: "2025-11-06",
                topic: nil,
                start: "2025-11-06 10:45",
                end: "2025-11-06 12:15",
                room: "3-3",
                status: 2,
                title: "Архитектура аппаратных средств",
                color: "green",
                type: "2"
            ),
            AttendanceRecord(
                clID: 2456,
                day: "2025-11-06",
                topic: nil,
                start: "2025-11-06 13:00",
                end: "2025-11-06 14:30",
                room: "2-5",
                status: 2,
                title: "История России",
                color: "green",
                type: nil
            ),
            AttendanceRecord(
                clID: 2457,
                day: "2025-11-06",
                topic: nil,
                start: "2025-11-06 14:45",
                end: "2025-11-06 16:15",
                room: "3-3",
                status: 1,
                title: "Введение в ООП",
                color: "green",
                type: "2"
            ),
            AttendanceRecord(
                clID: 2459,
                day: "2025-11-07",
                topic: nil,
                start: "2025-11-07 13:00",
                end: "2025-11-07 14:30",
                room: "404",
                status: 2,
                title: "Иностранный язык в профессиональной деятельности",
                color: "green",
                type: "2"
            )
        ]
    }
}
