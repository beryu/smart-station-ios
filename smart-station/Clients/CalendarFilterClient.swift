import ComposableArchitecture
import Foundation

struct CalendarFilterClient: Sendable {
    var loadSettings: @Sendable () async throws -> CalendarFilterSettings
    var saveSettings: @Sendable (_ settings: CalendarFilterSettings) async throws -> Void
}

extension CalendarFilterClient: DependencyKey {
    private static let storage = CalendarFilterStorage()

    static let liveValue = CalendarFilterClient(
        loadSettings: { try await storage.load() },
        saveSettings: { settings in try await storage.save(settings) }
    )

    static let testValue = CalendarFilterClient(
        loadSettings: { CalendarFilterSettings() },
        saveSettings: { _ in }
    )
}

extension DependencyValues {
    var calendarFilterClient: CalendarFilterClient {
        get { self[CalendarFilterClient.self] }
        set { self[CalendarFilterClient.self] = newValue }
    }
}

// MARK: - Thread-safe file storage

private actor CalendarFilterStorage {
    private let fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("calendar_filter_settings.json")
    }()

    func load() throws -> CalendarFilterSettings {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return CalendarFilterSettings()
        }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(CalendarFilterSettings.self, from: data)
    }

    func save(_ settings: CalendarFilterSettings) throws {
        let data = try JSONEncoder().encode(settings)
        try data.write(to: fileURL, options: .atomic)
    }
}
