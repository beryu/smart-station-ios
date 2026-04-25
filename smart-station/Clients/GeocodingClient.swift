import ComposableArchitecture
import Foundation

@DependencyClient
nonisolated struct GeocodingClient: Sendable {
    var search: @Sendable (_ query: String) async throws -> [GeocodingResult]
}

extension GeocodingClient: DependencyKey {
    static let liveValue = GeocodingClient(
        search: { query in
            var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")!
            components.queryItems = [
                .init(name: "name", value: query),
                .init(name: "count", value: "10"),
                .init(name: "language", value: "ja"),
            ]
            let (data, _) = try await URLSession.shared.data(from: components.url!)
            let response = try JSONDecoder().decode(GeocodingResponse.self, from: data)
            return response.results ?? []
        }
    )
}

extension DependencyValues {
    var geocodingClient: GeocodingClient {
        get { self[GeocodingClient.self] }
        set { self[GeocodingClient.self] = newValue }
    }
}
