//
//  AppUpdateChecker.swift
//  college-ios-app
//
//  Created by pc on 11.10.2025.
//

import Foundation

final class AppUpdateChecker {
    
    // MARK: - Singleton
    
    static let shared = AppUpdateChecker()
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let lastCheckDateKey = "lastUpdateCheckDate"
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Public Methods
    
    func shouldCheckForUpdate() -> Bool {
        guard let lastCheckDate = userDefaults.object(forKey: lastCheckDateKey) as? Date else {
            return true
        }
        
        let dayInSeconds: TimeInterval = 24 * 60 * 60
        let timeSinceLastCheck = Date().timeIntervalSince(lastCheckDate)
        
        return timeSinceLastCheck >= dayInSeconds
    }
    
    func checkForUpdate() async -> UpdateInfo? {
        guard let bundleId = Bundle.main.bundleIdentifier,
              let currentVersion = getCurrentVersion() else {
            return nil
        }
        
        guard let storeVersion = await fetchAppStoreVersion(bundleId: bundleId) else {
            return nil
        }
        
        userDefaults.set(Date(), forKey: lastCheckDateKey)
        
        if isNewerVersion(storeVersion, than: currentVersion) {
            return UpdateInfo(
                currentVersion: currentVersion,
                storeVersion: storeVersion,
                appStoreURL: "https://apps.apple.com/app/id\(bundleId)"
            )
        }
        
        return nil
    }
    
    // MARK: - Private Methods
    
    private func getCurrentVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    private func fetchAppStoreVersion(bundleId: String) async -> String? {
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let results = json["results"] as? [[String: Any]],
               let firstResult = results.first,
               let version = firstResult["version"] as? String {
                return version
            }
        } catch {
            
        }
        
        return nil
    }
    
    private func isNewerVersion(_ newVersion: String, than currentVersion: String) -> Bool {
        let newComponents = newVersion.split(separator: ".").compactMap { Int($0) }
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }
        
        let maxLength = max(newComponents.count, currentComponents.count)
        
        for i in 0..<maxLength {
            let new = i < newComponents.count ? newComponents[i] : 0
            let current = i < currentComponents.count ? currentComponents[i] : 0
            
            if new > current {
                return true
            } else if new < current {
                return false
            }
        }
        
        return false
    }
}

// MARK: - UpdateInfo

struct UpdateInfo {
    let currentVersion: String
    let storeVersion: String
    let appStoreURL: String
}
