import ComposableArchitecture
import Foundation

@Reducer
nonisolated struct CalendarEventsFeature {
    @ObservableState
    struct State: Equatable {
        var events: [CalendarEvent] = []
        var permissionStatus: CalendarPermissionStatus = .notDetermined
        var isLoading: Bool = false
        var errorMessage: String?
        var isMasked: Bool = false

        // Calendar filter
        var availableCalendars: [CalendarInfo] = []
        var excludedCalendarIDs: Set<String> = []
        var isFilterSheetPresented: Bool = false

        var filteredEvents: [CalendarEvent] {
            if excludedCalendarIDs.isEmpty { return events }
            return events.filter { !excludedCalendarIDs.contains($0.calendarID) }
        }
    }

    enum Action {
        case onAppear
        case fetchEvents
        case eventsResponse(Result<[CalendarEvent], Error>)
        case permissionResponse(CalendarPermissionStatus)
        case toggleMask
        case openSettingsTapped

        // Calendar filter
        case filterButtonTapped
        case dismissFilter
        case toggleCalendar(String)
        case availableCalendarsResponse([CalendarInfo])
        case filterSettingsLoaded(Result<CalendarFilterSettings, Error>)
    }

    @Dependency(\.calendarClient) var calendarClient
    @Dependency(\.calendarFilterClient) var calendarFilterClient
    @Dependency(\.date.now) var now

    private enum CancelID {
        case eventsFetch
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .run { send in
                        let status = await calendarClient.checkAuthorizationStatus()
                        await send(.permissionResponse(status))
                    },
                    .run { send in
                        let settings = try await calendarFilterClient.loadSettings()
                        await send(.filterSettingsLoaded(.success(settings)))
                    } catch: { error, send in
                        await send(.filterSettingsLoaded(.failure(error)))
                    }
                )

            case let .permissionResponse(status):
                state.permissionStatus = status
                switch status {
                case .authorized:
                    return .merge(
                        .send(.fetchEvents),
                        .run { send in
                            let calendars = await calendarClient.fetchAvailableCalendars()
                            await send(.availableCalendarsResponse(calendars))
                        }
                    )
                case .notDetermined:
                    return .run { send in
                        let granted = try await calendarClient.requestAccess()
                        await send(.permissionResponse(granted ? .authorized : .denied))
                    } catch: { _, send in
                        await send(.permissionResponse(.denied))
                    }
                case .denied, .restricted:
                    return .none
                }

            case .fetchEvents:
                state.isLoading = true
                state.errorMessage = nil
                let calendar = Calendar.current
                let startOfToday = calendar.startOfDay(for: now)
                guard let endDate = calendar.date(byAdding: .day, value: 8, to: startOfToday) else {
                    state.isLoading = false
                    return .none
                }
                let fromInterval = startOfToday.timeIntervalSinceReferenceDate
                let toInterval = endDate.timeIntervalSinceReferenceDate
                return .run { send in
                    let events = try await calendarClient.fetchUpcomingEvents(fromInterval, toInterval)
                    await send(.eventsResponse(.success(events)))
                } catch: { error, send in
                    await send(.eventsResponse(.failure(error)))
                }
                .cancellable(id: CancelID.eventsFetch)

            case let .eventsResponse(.success(events)):
                state.events = events
                state.isLoading = false
                return .none

            case .eventsResponse(.failure):
                state.isLoading = false
                state.errorMessage = "予定の取得に失敗しました"
                return .none

            case .toggleMask:
                state.isMasked.toggle()
                return .none

            case .openSettingsTapped:
                return .none

            case let .filterSettingsLoaded(.success(settings)):
                state.excludedCalendarIDs = settings.excludedCalendarIDs
                return .none

            case .filterSettingsLoaded(.failure):
                return .none

            case .filterButtonTapped:
                state.isFilterSheetPresented = true
                return .run { send in
                    let calendars = await calendarClient.fetchAvailableCalendars()
                    await send(.availableCalendarsResponse(calendars))
                }

            case let .availableCalendarsResponse(calendars):
                state.availableCalendars = calendars
                return .none

            case .dismissFilter:
                state.isFilterSheetPresented = false
                return .none

            case let .toggleCalendar(calendarID):
                if state.excludedCalendarIDs.contains(calendarID) {
                    state.excludedCalendarIDs.remove(calendarID)
                } else {
                    state.excludedCalendarIDs.insert(calendarID)
                }
                let settings = CalendarFilterSettings(excludedCalendarIDs: state.excludedCalendarIDs)
                return .run { _ in
                    try await calendarFilterClient.saveSettings(settings)
                }
            }
        }
    }
}
