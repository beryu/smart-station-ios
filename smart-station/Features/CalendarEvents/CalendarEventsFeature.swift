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
    }

    enum Action {
        case onAppear
        case fetchEvents
        case eventsResponse(Result<[CalendarEvent], Error>)
        case permissionResponse(CalendarPermissionStatus)
        case toggleMask
        case openSettingsTapped
    }

    @Dependency(\.calendarClient) var calendarClient
    @Dependency(\.date.now) var now

    private enum CancelID {
        case eventsFetch
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let status = await calendarClient.checkAuthorizationStatus()
                    await send(.permissionResponse(status))
                }

            case let .permissionResponse(status):
                state.permissionStatus = status
                switch status {
                case .authorized:
                    return .send(.fetchEvents)
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
            }
        }
    }
}
