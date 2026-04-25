import Foundation

struct CalendarEvent: Equatable, Identifiable, Sendable {
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

struct CalendarInfo: Equatable, Identifiable, Sendable, Codable {
    let id: String
    let title: String
    let colorHex: String
}

struct CalendarFilterSettings: Equatable, Sendable, Codable {
    var excludedCalendarIDs: Set<String> = []
}

enum CalendarPermissionStatus: Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
}
