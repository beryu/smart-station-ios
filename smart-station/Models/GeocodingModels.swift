import Foundation

nonisolated struct GeocodingResponse: Codable, Equatable, Sendable {
    let results: [GeocodingResult]?
}

nonisolated struct GeocodingResult: Codable, Equatable, Sendable, Identifiable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?
}
