import ComposableArchitecture
import SwiftUI

struct CenterPanelView: View {
    let store: StoreOf<DashboardFeature>

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundStyle(.blue)
                Text("気象詳細")
                    .font(.title3.bold())
            }

            WeatherDetailGridView(
                weatherResponse: store.weatherResponse,
                airQualityResponse: store.airQualityResponse,
                currentVisibility: store.currentVisibility
            )

            Spacer()
        }
    }
}
