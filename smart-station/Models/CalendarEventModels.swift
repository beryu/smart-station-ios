import Foundation

nonisolated struct CalendarEvent: Equatable, Identifiable, Sendable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let location: String?
    let calendarColorHex: String
    let calendarTitle: String
    let calendarID: String
}

nonisolated struct CalendarInfo: Equatable, Identifiable, Sendable, Codable {
    let id: String
    let title: String
    let colorHex: String
}

nonisolated struct CalendarFilterSettings: Equatable, Sendable, Codable {
    var excludedCalendarIDs: Set<String> = []
}

nonisolated enum CalendarPermissionStatus: Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
}
