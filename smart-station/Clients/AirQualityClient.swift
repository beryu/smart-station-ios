import ComposableArchitecture
import Foundation

@DependencyClient
struct AirQualityClient: Sendable {
    var fetchAirQuality: @Sendable (_ latitude: Double, _ longitude: Double) async throws -> AirQualityResponse
}

extension AirQualityClient: DependencyKey {
    static let liveValue = AirQualityClient(
        fetchAirQuality: { latitude, longitude in
            var components = URLComponents(string: "https://air-quality-api.open-meteo.com/v1/air-quality")!
            components.queryItems = [
                .init(name: "latitude", value: "\(latitude)"),
                .init(name: "longitude", value: "\(longitude)"),
                .init(name: "current", value: "us_aqi,pm2_5,pm10"),
                .init(name: "timezone", value: "auto"),
            ]
            let (data, _) = try await URLSession.shared.data(from: components.url!)
            return try JSONDecoder().decode(AirQualityResponse.self, from: data)
        }
    )
}

extension DependencyValues {
    var airQualityClient: AirQualityClient {
        get { self[AirQualityClient.self] }
        set { self[AirQualityClient.self] = newValue }
    }
}
