import SwiftUI

struct WeatherDetailGridView: View {
    let weatherResponse: WeatherResponse?
    let airQualityResponse: AirQualityResponse?
    let currentVisibility: Double?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            WeatherDetailCard(
                title: "AQI",
                value: airQualityResponse?.current?.usAqi.map { "\($0)" } ?? "--",
                icon: "aqi.medium",
                color: .aqiColor(airQualityResponse?.current?.usAqi)
            )
            WeatherDetailCard(
                title: "PM2.5",
                value: airQualityResponse?.current?.pm25.map { String(format: "%.1f μg/m³", $0) } ?? "--",
                icon: "aqi.low",
                color: .purple
            )
            WeatherDetailCard(
                title: "風速",
                value: weatherResponse.map { "\(String(format: "%.1f", $0.current.windSpeed10m)) km/h" } ?? "--",
                icon: "wind",
                color: .teal
            )
            WeatherDetailCard(
                title: "風向",
                value: weatherResponse.map { "\(Formatters.windDirection($0.current.windDirection10m)) \(Int($0.current.windDirection10m))°" } ?? "--",
                icon: "safari",
                color: .teal
            )
            WeatherDetailCard(
                title: "UV指数",
                value: weatherResponse?.daily.uvIndexMax.first.map { String(format: "%.0f", $0) } ?? "--",
                icon: "sun.max.trianglebadge.exclamationmark",
                color: .yellow
            )
            WeatherDetailCard(
                title: "降水量",
                value: weatherResponse.map { "\($0.current.precipitation) mm" } ?? "--",
                icon: "drop.fill",
                color: .blue
            )
            WeatherDetailCard(
                title: "視程",
                value: currentVisibility.map { Formatters.visibility($0) } ?? "--",
                icon: "eye.fill",
                color: .mint
            )
            WeatherDetailCard(
                title: "気圧",
                value: weatherResponse.map { "\(Int($0.current.surfacePressure)) hPa" } ?? "--",
                icon: "gauge.with.dots.needle.bottom.50percent",
                color: .indigo
            )
        }
    }
}
