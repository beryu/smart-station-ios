import ComposableArchitecture
import SwiftUI

struct RightPanelView: View {
  let store: StoreOf<DashboardFeature>

  var body: some View {
    if let articleURL = store.selectedArticleURL {
      VStack(spacing: 0) {
        HStack {
          Image(systemName: "newspaper.fill")
            .foregroundStyle(.blue)
          Text("記事")
            .font(.title3.bold())
          Spacer()
          Button {
            store.send(.closeArticle)
          } label: {
            Image(systemName: "xmark.circle.fill")
              .font(.title2)
              .foregroundStyle(.secondary)
          }
          .buttonStyle(.plain)
        }
        .padding(.bottom, 8)

        ArticleWebView(url: articleURL)
          .clipShape(RoundedRectangle(cornerRadius: 12))
      }
    } else {
      ScrollView {
        VStack(spacing: 16) {
          // Current weather card
          CurrentWeatherCard(
            weatherCode: store.currentWeatherCode,
            temperature: store.currentTemperature,
            apparentTemperature: store.weatherResponse?.current.apparentTemperature,
            highTemp: store.todayHigh,
            lowTemp: store.todayLow
          )

          // Humidity
          HStack(spacing: 12) {
            WeatherDetailCard(
              title: "気温",
              value: Formatters.temperature(store.currentTemperature),
              icon: "thermometer.medium",
              color: .orange
            )
            WeatherDetailCard(
              title: "湿度",
              value: Formatters.percentage(store.currentHumidity),
              icon: "humidity.fill",
              color: .cyan
            )
          }

          // Sunrise / Sunset
          SunriseSunsetView(
            sunrise: store.sunrise,
            sunset: store.sunset
          )

          HStack {
            Image(systemName: "calendar")
              .foregroundStyle(.blue)
            Text("週間予報")
              .font(.title3.bold())
          }

          SevenDayForecastView(forecasts: store.dailyForecasts)

          Spacer()

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

        }
      }
      .scrollIndicators(.hidden)
      .onAppear {
        store.send(.calendarEvents(.onAppear))
      }
    }
  }
}
