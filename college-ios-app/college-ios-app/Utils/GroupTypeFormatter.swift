import Foundation

enum GroupTypeFormatter {
    static func format(_ groupType: String) -> String {
        switch groupType {
        case "BE": return "Backend"
        case "FE": return "Frontend"
        case "GD": return "Game Dev"
        case "PM": return "Project Management"
        case "SA": return "System Administration"
        case "CD": return "UX/UI Design"
        default: return groupType
        }
    }
    
    static func isKnownGroupType(_ groupType: String) -> Bool {
        ["BE", "FE", "GD", "PM", "SA", "CD"].contains(groupType)
    }
    
    // MARK: - Subgroup Formatting
    
    static func formatSubgroup(_ subgroup: String) -> String {
        if subgroup == "*" {
            return "Вся группа"
        }
        
        if let formatted = formatStandardSubgroup(subgroup) {
            return formatted
        }
        
        if isKnownGroupType(subgroup) {
            return "\(format(subgroup)) (\(subgroup))"
        }
        
        return subgroup
    }
    
    static func formatProfileSubgroup(_ subgroup: String) -> String {
        if subgroup == "*" {
            return "Нет подгруппы"
        }
        
        if let formatted = formatStandardSubgroup(subgroup) {
            return formatted
        }
        
        return subgroup
    }
    
    private static func formatStandardSubgroup(_ subgroup: String) -> String? {
        let prefix = "Подгр"
        guard subgroup.hasPrefix(prefix) else { return nil }
        
        let number = subgroup.dropFirst(prefix.count)
        guard !number.isEmpty else { return nil }
        
        return "Подгруппа \(number)"
    }
}
