import Foundation

nonisolated struct AirQualityResponse: Codable, Equatable, Sendable {
    let current: AirQualityCurrent?
    let hourly: AirQualityHourly?
}

nonisolated struct AirQualityCurrent: Codable, Equatable, Sendable {
    let time: String
    let usAqi: Int?
    let pm25: Double?
    let pm10: Double?

    enum CodingKeys: String, CodingKey {
        case time
        case usAqi = "us_aqi"
        case pm25 = "pm2_5"
        case pm10
    }
}

nonisolated struct AirQualityHourly: Codable, Equatable, Sendable {
    let time: [String]
    let pm25: [Double?]
    let pm10: [Double?]
    let usAqi: [Int?]

    enum CodingKeys: String, CodingKey {
        case time
        case pm25 = "pm2_5"
        case pm10
        case usAqi = "us_aqi"
    }
}
