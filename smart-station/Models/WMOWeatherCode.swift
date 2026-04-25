import Foundation

nonisolated enum WMOWeatherCode: Int, CaseIterable, Sendable {
    case clearSky = 0
    case mainlyClear = 1
    case partlyCloudy = 2
    case overcast = 3
    case fog = 45
    case depositingRimeFog = 48
    case drizzleLight = 51
    case drizzleModerate = 53
    case drizzleDense = 55
    case freezingDrizzleLight = 56
    case freezingDrizzleDense = 57
    case rainSlight = 61
    case rainModerate = 63
    case rainHeavy = 65
    case freezingRainLight = 66
    case freezingRainHeavy = 67
    case snowFallSlight = 71
    case snowFallModerate = 73
    case snowFallHeavy = 75
    case snowGrains = 77
    case rainShowersSlight = 80
    case rainShowersModerate = 81
    case rainShowersViolent = 82
    case snowShowersSlight = 85
    case snowShowersHeavy = 86
    case thunderstorm = 95
    case thunderstormWithSlightHail = 96
    case thunderstormWithHeavyHail = 99

    var description: String {
        switch self {
        case .clearSky: "Clear"
        case .mainlyClear: "Mostly Clear"
        case .partlyCloudy: "Partly Cloudy"
        case .overcast: "Overcast"
        case .fog, .depositingRimeFog: "Foggy"
        case .drizzleLight: "Light Drizzle"
        case .drizzleModerate: "Drizzle"
        case .drizzleDense: "Heavy Drizzle"
        case .freezingDrizzleLight, .freezingDrizzleDense: "Freezing Drizzle"
        case .rainSlight: "Light Rain"
        case .rainModerate: "Rain"
        case .rainHeavy: "Heavy Rain"
        case .freezingRainLight, .freezingRainHeavy: "Freezing Rain"
        case .snowFallSlight: "Light Snow"
        case .snowFallModerate: "Snow"
        case .snowFallHeavy: "Heavy Snow"
        case .snowGrains: "Snow Grains"
        case .rainShowersSlight: "Light Showers"
        case .rainShowersModerate: "Showers"
        case .rainShowersViolent: "Heavy Showers"
        case .snowShowersSlight: "Light Snow Showers"
        case .snowShowersHeavy: "Heavy Snow Showers"
        case .thunderstorm: "Thunderstorm"
        case .thunderstormWithSlightHail, .thunderstormWithHeavyHail: "Thunderstorm with Hail"
        }
    }

    var sfSymbolName: String {
        switch self {
        case .clearSky: "sun.max.fill"
        case .mainlyClear: "sun.min.fill"
        case .partlyCloudy: "cloud.sun.fill"
        case .overcast: "cloud.fill"
        case .fog, .depositingRimeFog: "cloud.fog.fill"
        case .drizzleLight, .drizzleModerate, .drizzleDense: "cloud.drizzle.fill"
        case .freezingDrizzleLight, .freezingDrizzleDense: "cloud.sleet.fill"
        case .rainSlight, .rainModerate: "cloud.rain.fill"
        case .rainHeavy: "cloud.heavyrain.fill"
        case .freezingRainLight, .freezingRainHeavy: "cloud.sleet.fill"
        case .snowFallSlight, .snowFallModerate, .snowFallHeavy, .snowGrains: "cloud.snow.fill"
        case .rainShowersSlight, .rainShowersModerate: "cloud.rain.fill"
        case .rainShowersViolent: "cloud.heavyrain.fill"
        case .snowShowersSlight, .snowShowersHeavy: "cloud.snow.fill"
        case .thunderstorm: "cloud.bolt.fill"
        case .thunderstormWithSlightHail, .thunderstormWithHeavyHail: "cloud.bolt.rain.fill"
        }
    }
}
