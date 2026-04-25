import ComposableArchitecture
import Foundation

@Reducer
nonisolated struct LocationSearchFeature {
    @ObservableState
    struct State: Equatable {
        var searchText: String = ""
        var results: [GeocodingResult] = []
        var isSearching: Bool = false
    }

    enum Action: Equatable {
        case searchTextChanged(String)
        case searchResponse([GeocodingResult])
        case resultTapped(GeocodingResult)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case locationSelected(GeocodingResult)
        }
    }

    @Dependency(\.geocodingClient) var geocodingClient
    @Dependency(\.continuousClock) var clock

    private enum CancelID { case search }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .searchTextChanged(text):
                state.searchText = text
                guard text.count >= 2 else {
                    state.results = []
                    return .cancel(id: CancelID.search)
                }
                state.isSearching = true
                let continuousClock = self.clock
                let geocoding = self.geocodingClient
                return .run { send in
                    try await continuousClock.sleep(for: .milliseconds(300))
                    let results = try await geocoding.search(text)
                    await send(.searchResponse(results))
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)

            case let .searchResponse(results):
                state.results = results
                state.isSearching = false
                return .none

            case let .resultTapped(result):
                return .send(.delegate(.locationSelected(result)))

            case .delegate:
                return .none
            }
        }
    }
}
