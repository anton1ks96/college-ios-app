//
//  GroupSubgroupCompatibility.swift
//  college-ios-app
//
//  Created by pc on 22.09.2025.
//

import Foundation

struct GroupSubgroupCompatibility {
    
    // MARK: - Static Data
    
    private static let allSubgroup = "*"
    
    private static let firstYearSubgroups = ["Подгр1", "Подгр2", "Подгр3", "Подгр4"]
    
    private static let profiles = ["BE", "FE", "GD", "PM", "SA", "CD"]
    
    private static let englishByYear: [String: [String]] = [
        "25": ["A0.11", "A0.12", "A1.11", "A1.12", "A2.11", "A2.12", "B1.11", "B1.12"],
        "24": ["A0.21", "A1.21", "A1.22", "A1.23", "A2.21", "A2.22", "B1.21", "B1.22"],
        "23": ["A1.31", "A2.31", "B1.31"],
        "22": ["A1.41", "A2.41", "B1.41"]
    ]
    
    // MARK: - Public Methods
    
    static func getYear(from group: String) -> String? {
        let components = group.components(separatedBy: CharacterSet.decimalDigits.inverted)
        return components.first(where: { $0.count == 2 })
    }
    
    static func availableSubgroups(for group: String) -> [String] {
        guard let year = getYear(from: group) else {
            return [allSubgroup]
        }
        
        var subgroups: [String] = [allSubgroup]
        
        switch year {
        case "25":
            subgroups.append(contentsOf: firstYearSubgroups)
            subgroups.append(contentsOf: englishByYear["25"] ?? [])
            
        case "24", "23", "22":
            subgroups.append(contentsOf: profiles)
            subgroups.append(contentsOf: englishByYear[year] ?? [])
            
        default:
            break
        }
        
        return subgroups
    }
    
    static func isValidSubgroup(_ subgroup: String, for group: String) -> Bool {
        let availableSubgroups = availableSubgroups(for: group)
        return availableSubgroups.contains(subgroup)
    }
    
    static func validatedSubgroup(_ current: String, for group: String) -> String {
        if isValidSubgroup(current, for: group) {
            return current
        }
        return allSubgroup
    }
}
