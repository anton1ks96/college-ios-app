//
//  UserSettingsRepositoryProtocol.swift
//  college-ios-app
//
//  Created by pc on 22.09.2025.
//

import Foundation

protocol UserSettingsRepositoryProtocol {
    var selectedGroup: String { get set }
    
    var selectedSubgroup: String { get set }
    
    func hasStoredSettings() -> Bool
}
