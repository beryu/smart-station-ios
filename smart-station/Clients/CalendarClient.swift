import ComposableArchitecture
import EventKit
import Foundation
import UIKit

@DependencyClient
struct CalendarClient: Sendable {
    var requestAccess: @Sendable () async throws -> Bool
    var checkAuthorizationStatus: @Sendable () async -> CalendarPermissionStatus = { .notDetermined }
    var fetchUpcomingEvents: @Sendable (_ fromInterval: TimeInterval, _ toInterval: TimeInterval) async throws -> [CalendarEvent]
}

// MARK: - MainActor-isolated EventKit wrapper

@MainActor
private final class EventKitStore {
    static let shared = EventKitStore()
    private var store: EKEventStore?

    private func getStore() -> EKEventStore {
        if let store {
            return store
        }
        let newStore = EKEventStore()
        store = newStore
        return newStore
    }

    func requestAccess() async throws -> Bool {
        let eventStore = getStore()
        let granted = try await eventStore.requestFullAccessToEvents()
        if granted {
            // Reset after first grant so the store can see calendar data
            eventStore.reset()
        }
        return granted
    }

    func checkAuthorizationStatus() -> CalendarPermissionStatus {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess, .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        case .writeOnly:
            return .denied
        @unknown default:
            return .notDetermined
        }
    }

    func fetchUpcomingEvents(fromInterval: TimeInterval, toInterval: TimeInterval) -> [CalendarEvent] {
        let status = EKEventStore.authorizationStatus(for: .event)
        guard status == .fullAccess || status == .authorized else {
            return []
        }
        let fromDate = Date(timeIntervalSinceReferenceDate: fromInterval)
        let toDate = Date(timeIntervalSinceReferenceDate: toInterval)
        // Create a fresh store each time to avoid stale internal state
        let freshStore = EKEventStore()
        let predicate = freshStore.predicateForEvents(
            withStart: fromDate,
            end: toDate,
            calendars: nil
        )
        let ekEvents = freshStore.events(matching: predicate)
        var results: [CalendarEvent] = []
        for event in ekEvents.prefix(15) {
            let hex: String
            if let cal = event.calendar, let cgColor = cal.cgColor {
                let uiColor = UIColor(cgColor: cgColor)
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
                uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
                hex = String(
                    format: "#%02X%02X%02X",
                    Int(r * 255), Int(g * 255), Int(b * 255)
                )
            } else {
                hex = "#808080"
            }
            results.append(CalendarEvent(
                id: event.eventIdentifier ?? UUID().uuidString,
                title: event.title ?? "",
                startDate: event.startDate,
                endDate: event.endDate,
                isAllDay: event.isAllDay,
                location: event.location,
                calendarColorHex: hex,
                calendarTitle: event.calendar?.title ?? ""
            ))
        }
        return results
    }
}

// MARK: - DependencyKey

extension CalendarClient: DependencyKey {
    static let liveValue = CalendarClient(
        requestAccess: {
            try await EventKitStore.shared.requestAccess()
        },
        checkAuthorizationStatus: {
            await EventKitStore.shared.checkAuthorizationStatus()
        },
        fetchUpcomingEvents: { fromInterval, toInterval in
            await EventKitStore.shared.fetchUpcomingEvents(fromInterval: fromInterval, toInterval: toInterval)
        }
    )
}

extension DependencyValues {
    var calendarClient: CalendarClient {
        get { self[CalendarClient.self] }
        set { self[CalendarClient.self] = newValue }
    }
}
