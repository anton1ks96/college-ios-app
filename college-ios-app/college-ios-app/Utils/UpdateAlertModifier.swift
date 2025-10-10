//
//  UpdateAlertModifier.swift
//  college-ios-app
//
//  Created by pc on 11.10.2025.
//

import SwiftUI

struct UpdateAlertModifier: ViewModifier {
    
    @State private var updateInfo: UpdateInfo?
    @State private var showUpdateAlert = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                Task {
                    await checkForUpdate()
                }
            }
            .alert("Доступно обновление", isPresented: $showUpdateAlert) {
                Button("Позже", role: .cancel) {
                    showUpdateAlert = false
                }
                
                Button("Обновить") {
                    openAppStore()
                }
            } message: {
                if let updateInfo = updateInfo {
                    Text("Доступна новая версия \(updateInfo.storeVersion). Ваша текущая версия: \(updateInfo.currentVersion)")
                }
            }
    }
    
    // MARK: - Private Methods
    
    private func checkForUpdate() async {
        guard AppUpdateChecker.shared.shouldCheckForUpdate() else {
            return
        }
        
        if let info = await AppUpdateChecker.shared.checkForUpdate() {
            await MainActor.run {
                self.updateInfo = info
                self.showUpdateAlert = true
            }
        }
    }
    
    private func openAppStore() {
        guard let updateInfo = updateInfo,
              let url = URL(string: updateInfo.appStoreURL) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - View Extension

extension View {
    func checkForAppUpdates() -> some View {
        self.modifier(UpdateAlertModifier())
    }
}

// MARK: - Preview

#Preview("Update Alert") {
    UpdateAlertPreviewView()
}

private struct UpdateAlertPreviewView: View {
    @State private var showAlert = true
    
    var body: some View {
        VStack {
            Text("Preview Update Alert")
                .font(.title)
            
            Button("Показать Alert") {
                showAlert = true
            }
            .buttonStyle(.borderedProminent)
        }
        .alert("Доступно обновление", isPresented: $showAlert) {
            Button("Позже", role: .cancel) {
                showAlert = false
            }
            
            Button("Обновить") {
                showAlert = false
            }
        } message: {
            Text("Доступна новая версия 1.1.0. Ваша текущая версия: 1.0.0")
        }
    }
}
