//
//  UserSettingsRepository.swift
//  college-ios-app
//
//  Created by pc on 22.09.2025.
//

import Foundation

final class UserSettingsRepository: UserSettingsRepositoryProtocol {
    
    // MARK: - Constants
    private enum Keys {
        static let selectedGroup = "com.college.selectedGroup"
        static let selectedSubgroup = "com.college.selectedSubgroup"
        static let hasStoredSettings = "com.college.hasStoredSettings"
    }
    
    // MARK: - Properties
    private let userDefaults: UserDefaults
    
    // MARK: - Default Values
    private let defaultGroup: String
    private let defaultSubgroup: String
    
    // MARK: - Init
    init(
        userDefaults: UserDefaults = .standard,
        defaultGroup: String? = nil,
        defaultSubgroup: String? = nil
    ) {
        self.userDefaults = userDefaults
        self.defaultGroup = defaultGroup ?? GroupsCatalog.allGroups.first ?? ""
        self.defaultSubgroup = defaultSubgroup ?? "*"
    }
    
    // MARK: - UserSettingsRepositoryProtocol
    
    var selectedGroup: String {
        get {
            guard let saved = userDefaults.string(forKey: Keys.selectedGroup) else {
                return defaultGroup
            }

            if GroupsCatalog.allGroups.contains(saved) {
                return saved
            } else {
                return defaultGroup
            }
        }
        set {
            userDefaults.set(newValue, forKey: Keys.selectedGroup)
            userDefaults.set(true, forKey: Keys.hasStoredSettings)
            CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
        }
    }
    
    var selectedSubgroup: String {
        get {
            let group = selectedGroup
            
            guard let saved = userDefaults.string(forKey: Keys.selectedSubgroup) else {
                return defaultSubgroup
            }

            if GroupSubgroupCompatibility.isValidSubgroup(saved, for: group) {
                return saved
            } else {
                return defaultSubgroup
            }
        }
        set {
            userDefaults.set(newValue, forKey: Keys.selectedSubgroup)
            userDefaults.set(true, forKey: Keys.hasStoredSettings)
            CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
        }
    }
    
    func hasStoredSettings() -> Bool {
        return userDefaults.bool(forKey: Keys.hasStoredSettings)
    }
}

// MARK: - Convenience Methods
extension UserSettingsRepository {
    func updateSettings(group: String, subgroup: String) {
        selectedGroup = group
        let validatedSubgroup = GroupSubgroupCompatibility.validatedSubgroup(subgroup, for: group)
        selectedSubgroup = validatedSubgroup
    }
    
    func validateStoredSettings() -> Bool {
        let groupValid = GroupsCatalog.allGroups.contains(selectedGroup)
        let subgroupValid = GroupSubgroupCompatibility.isValidSubgroup(selectedSubgroup, for: selectedGroup)
        return groupValid && subgroupValid
    }
}
