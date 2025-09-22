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
}
