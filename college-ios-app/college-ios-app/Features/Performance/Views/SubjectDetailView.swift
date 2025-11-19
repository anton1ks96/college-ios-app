//
//  SubjectDetailView.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import SwiftUI

struct SubjectDetailView: View {
    @ObservedObject var viewModel: SubjectDetailViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.lessons.isEmpty {
                loadingView
            } else if let error = viewModel.errorMessage, viewModel.lessons.isEmpty {
                errorView(message: error)
            } else {
                detailContent
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.subject.title).font(.headline)
            }
        }
        .task {
            viewModel.onAppearOnce()
        }
    }
    
    private var detailContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                StatisticsCard(statistics: viewModel.statistics)
                
                if !viewModel.lessonsWithGradedScores.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Выставленные оценки")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.lessonsWithGradedScores) { lesson in
                                LessonScoreCard(lesson: lesson, showOnlyGraded: true)
                            }
                        }
                    }
                }
                
                if !viewModel.lessonsWithPendingScores.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ожидают оценки")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.lessonsWithPendingScores) { lesson in
                                LessonScoreCard(lesson: lesson, showOnlyGraded: false)
                            }
                        }
                    }
                }
                
                if viewModel.lessons.isEmpty {
                    emptyMessage
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Загрузка оценок...")
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
    
    private var emptyMessage: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Нет оценок за текущее полугодие")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
