import ComposableArchitecture
import SwiftUI

struct RightPanelView: View {
    let store: StoreOf<DashboardFeature>

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                Text("週間予報")
                    .font(.title3.bold())
            }

            SevenDayForecastView(forecasts: store.dailyForecasts)

            // Additional locations
            if !store.additionalLocations.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(.blue)
                        Text("登録地域")
                            .font(.subheadline.bold())
                        Spacer()
                    }

                    ForEach(store.additionalLocations) { location in
                        Button {
                            store.send(.selectLocation(location.id))
                        } label: {
                            HStack {
                                Text(location.name)
                                    .font(.callout)
                                Spacer()
                                if store.selectedLocationID == location.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }

                    if store.selectedLocationID != nil {
                        Button {
                            store.send(.selectLocation(nil))
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("現在地に戻す")
                                    .font(.caption)
                            }
                            .foregroundStyle(.blue)
                        }
                    }
                }
            }

            Spacer()
        }
    }
}
