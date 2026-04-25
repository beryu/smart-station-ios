import ComposableArchitecture
import SwiftUI

struct LeftPanelView: View {
    let store: StoreOf<DashboardFeature>

    var body: some View {
        VStack(spacing: 20) {
            // Location name
            HStack {
                Image(systemName: store.currentLocation?.isCurrentLocation == true ? "location.fill" : "mappin.circle.fill")
                    .foregroundStyle(.blue)
                Text(store.locationName)
                    .font(.title3.bold())
            }

            // Clock
            ClockView(store: store.scope(state: \.clock, action: \.clock))

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

            Spacer()
        }
    }
}
