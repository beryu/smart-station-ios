import Foundation

nonisolated struct WeatherResponse: Codable, Equatable, Sendable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let current: CurrentWeather
    let hourly: HourlyWeather
    let daily: DailyWeather
}

nonisolated struct CurrentWeather: Codable, Equatable, Sendable {
    let time: String
    let temperature2m: Double
    let relativeHumidity2m: Int
    let apparentTemperature: Double
    let precipitation: Double
    let weatherCode: Int
    let surfacePressure: Double
    let windSpeed10m: Double
    let windDirection10m: Double
    let cloudCover: Int

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case apparentTemperature = "apparent_temperature"
        case precipitation
        case weatherCode = "weather_code"
        case surfacePressure = "surface_pressure"
        case windSpeed10m = "wind_speed_10m"
        case windDirection10m = "wind_direction_10m"
        case cloudCover = "cloud_cover"
    }
}

nonisolated struct HourlyWeather: Codable, Equatable, Sendable {
    let time: [String]
    let visibility: [Double?]
}

nonisolated struct DailyWeather: Codable, Equatable, Sendable {
    let time: [String]
    let weatherCode: [Int]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let precipitationSum: [Double]
    let precipitationProbabilityMax: [Int]
    let sunrise: [String]
    let sunset: [String]
    let uvIndexMax: [Double]
    let windSpeed10mMax: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationSum = "precipitation_sum"
        case precipitationProbabilityMax = "precipitation_probability_max"
        case sunrise, sunset
        case uvIndexMax = "uv_index_max"
        case windSpeed10mMax = "wind_speed_10m_max"
    }
}

nonisolated struct DailyForecast: Equatable, Identifiable, Sendable {
    var id: String { date }
    let date: String
    let weatherCode: Int
    let highTemp: Double
    let lowTemp: Double
    let precipitationProbability: Int
    let precipitationSum: Double
}
