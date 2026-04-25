import ComposableArchitecture
import SwiftUI

struct ClockView: View {
    let store: StoreOf<ClockFeature>

    var body: some View {
        VStack(spacing: 4) {
            Text(Formatters.fullDate(from: store.currentDate))
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary.opacity(0.85))

            Text(store.currentDate, format: .dateTime.hour().minute())
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.primary)

            Text(String(format: "%02d", Calendar.current.component(.second, from: store.currentDate)))
                .font(.system(size: 24, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
