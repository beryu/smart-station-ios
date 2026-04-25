import ComposableArchitecture
import Foundation

@Reducer
nonisolated struct ClockFeature {
    @ObservableState
    struct State: Equatable {
        var currentDate: Date = Date()
    }

    enum Action {
        case start
        case stop
        case tick
    }

    @Dependency(\.continuousClock) var clock

    private enum CancelID { case timer }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .start:
                let clock = self.clock
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(.tick)
                    }
                }
                .cancellable(id: CancelID.timer)

            case .stop:
                return .cancel(id: CancelID.timer)

            case .tick:
                state.currentDate = Date()
                return .none
            }
        }
    }
}
