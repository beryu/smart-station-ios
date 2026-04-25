import ComposableArchitecture
import SwiftUI

struct ClockView: View {
    let store: StoreOf<ClockFeature>

    var body: some View {
        VStack(spacing: 2) {
            Text(Formatters.fullDate(from: store.currentDate))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(store.currentDate, format: .dateTime.hour().minute())
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.primary)

            Text(store.currentDate, format: .dateTime.second())
                .font(.system(size: 24, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
