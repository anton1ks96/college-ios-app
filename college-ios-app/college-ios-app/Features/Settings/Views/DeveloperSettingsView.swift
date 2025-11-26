//
//  DeveloperSettingsView.swift
//  college-ios-app
//
//  Created by pc on 24.11.2025.
//

import SwiftUI
import WidgetKit

struct DeveloperSettingsView: View {
    
    @State private var showClearCacheAlert = false
    @State private var showClearedToast = false
    @State private var deviceInfo = DeviceInfo()
    
    var body: some View {
        List {
            infoSection
            streakDebugSection
            actionsSection
        }
        .navigationTitle("Developer")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Очистить кэш?", isPresented: $showClearCacheAlert) {
            Button("Отмена", role: .cancel) {}
            Button("Очистить", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("Будут сброшены все настройки приложения. Это действие нельзя отменить.")
        }
        .overlay(alignment: .bottom) {
            if showClearedToast {
                toastView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: showClearedToast)
        .onAppear {
            deviceInfo.refresh()
        }
    }
    
    // MARK: - Info Section
    
    private var infoSection: some View {
        Section {
            InfoRow(title: "Версия", value: deviceInfo.appVersion)
            InfoRow(title: "Build", value: deviceInfo.buildNumber)
            InfoRow(title: "Устройство", value: deviceInfo.deviceModel)
            InfoRow(title: "iOS", value: deviceInfo.iosVersion)
            InfoRow(title: "Размер кэша", value: deviceInfo.cacheSize)
            InfoRow(title: "Установлено", value: deviceInfo.installDate)
            InfoRow(title: "Bundle ID", value: deviceInfo.bundleId)
        } header: {
            Text("Информация")
        }
    }
    
    // MARK: - Streak Debug Section
    
    private var streakDebugSection: some View {
        Section {
            let storage = StreakStorage()
            let lastKnown = storage.lastKnownStreak
            
            HStack {
                Text("lastKnownStreak")
                Spacer()
                Text(lastKnown.map { "\($0)" } ?? "nil")
                    .foregroundStyle(.secondary)
            }
            
            Button {
                resetStreakStorage()
            } label: {
                Label {
                    Text("Сбросить streak")
                        .foregroundStyle(.orange)
                } icon: {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                }
            }
        } header: {
            Text("Streak Debug")
        } footer: {
            Text("После сброса при следующем запуске увидите анимацию +N с полным значением streak")
        }
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        Section {
            Button {
                showClearCacheAlert = true
            } label: {
                Label {
                    Text("Очистить кэш (UserDefaults)")
                        .foregroundStyle(.red)
                } icon: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
            Button {
                reloadWidgets()
            } label: {
                Label("Перезагрузить виджеты", systemImage: "arrow.clockwise")
            }
        } header: {
            Text("Действия")
        }
    }
    
    // MARK: - Toast
    
    private var toastView: some View {
        Text("Готово")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.green, in: Capsule())
            .padding(.bottom, 20)
    }
    
    // MARK: - Actions
    
    private func clearCache() {
        let appGroupDefaults = UserDefaults(suiteName: "group.com.college.MyKCT")
        let standardDefaults = UserDefaults.standard
        
        if let appGroupDefaults {
            for key in appGroupDefaults.dictionaryRepresentation().keys {
                appGroupDefaults.removeObject(forKey: key)
            }
            appGroupDefaults.synchronize()
        }
        
        let systemPrefixes = ["Apple", "NS", "com.apple"]
        for key in standardDefaults.dictionaryRepresentation().keys {
            let isSystemKey = systemPrefixes.contains { key.hasPrefix($0) }
            if !isSystemKey {
                standardDefaults.removeObject(forKey: key)
            }
        }
        standardDefaults.synchronize()
        
        URLCache.shared.removeAllCachedResponses()
        WidgetCenter.shared.reloadAllTimelines()
        
        deviceInfo.refresh()
        
        showClearedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showClearedToast = false
        }
    }
    
    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
        
        showClearedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showClearedToast = false
        }
    }
    
    private func resetStreakStorage() {
        let storage = StreakStorage()
        storage.lastKnownStreak = nil
        
        showClearedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showClearedToast = false
        }
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
    }
}

// MARK: - Device Info

@Observable
private class DeviceInfo {
    var appVersion = "-"
    var buildNumber = "-"
    var deviceModel = "-"
    var iosVersion = "-"
    var cacheSize = "-"
    var installDate = "-"
    var bundleId = "-"
    
    func refresh() {
        let bundle = Bundle.main
        
        appVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        buildNumber = bundle.infoDictionary?["CFBundleVersion"] as? String ?? "-"
        bundleId = bundle.bundleIdentifier ?? "-"
        
        deviceModel = getDeviceModel()
        iosVersion = UIDevice.current.systemVersion
        
        cacheSize = calculateCacheSize()
        installDate = getInstallDate()
    }
    
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingCString: $0)
            }
        }
        return modelCode ?? UIDevice.current.model
    }
    
    private func calculateCacheSize() -> String {
        var totalSize: Int64 = 0
        
        totalSize += Int64(URLCache.shared.currentDiskUsage)
        
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            totalSize += directorySize(url: documentsURL)
        }
        
        if let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            totalSize += directorySize(url: cachesURL)
        }
        
        return ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
    
    private func directorySize(url: URL) -> Int64 {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var size: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                  let fileSize = resourceValues.fileSize else {
                continue
            }
            size += Int64(fileSize)
        }
        return size
    }
    
    private func getInstallDate() -> String {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let attributes = try? FileManager.default.attributesOfItem(atPath: documentsURL.path),
              let creationDate = attributes[.creationDate] as? Date else {
            return "-"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: creationDate)
    }
}

#Preview {
    NavigationStack {
        DeveloperSettingsView()
    }
}
