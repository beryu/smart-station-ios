import ComposableArchitecture
import Foundation

@DependencyClient
struct WeatherClient: Sendable {
    var fetchWeather: @Sendable (_ latitude: Double, _ longitude: Double) async throws -> WeatherResponse
}

extension WeatherClient: DependencyKey {
    static let liveValue = WeatherClient(
        fetchWeather: { latitude, longitude in
            var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
            components.queryItems = [
                .init(name: "latitude", value: "\(latitude)"),
                .init(name: "longitude", value: "\(longitude)"),
                .init(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,surface_pressure,wind_speed_10m,wind_direction_10m,cloud_cover"),
                .init(name: "hourly", value: "visibility"),
                .init(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,sunrise,sunset,uv_index_max,wind_speed_10m_max"),
                .init(name: "timezone", value: "auto"),
                .init(name: "forecast_days", value: "7"),
            ]
            let (data, _) = try await URLSession.shared.data(from: components.url!)
            return try JSONDecoder().decode(WeatherResponse.self, from: data)
        }
    )
}

extension DependencyValues {
    var weatherClient: WeatherClient {
        get { self[WeatherClient.self] }
        set { self[WeatherClient.self] = newValue }
    }
}
