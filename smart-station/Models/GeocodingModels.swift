import Foundation

struct GeocodingResponse: Codable, Equatable, Sendable {
    let results: [GeocodingResult]?
}

struct GeocodingResult: Codable, Equatable, Sendable, Identifiable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?
}
