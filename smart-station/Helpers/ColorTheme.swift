import SwiftUI

extension Color {
    enum theme {
        static let backgroundTop = Color(red: 0.05, green: 0.08, blue: 0.22)
        static let backgroundBottom = Color(red: 0.08, green: 0.12, blue: 0.30)
        static let cardBackground = Color.white.opacity(0.08)
        static let temperatureHot = Color.orange
        static let temperatureCold = Color.cyan
        static let rain = Color.blue
        static let wind = Color.teal
        static let uv = Color.yellow
    }

    static func aqiColor(_ aqi: Int?) -> Color {
        guard let aqi else { return .gray }
        switch aqi {
        case 0...50: return .green
        case 51...100: return .yellow
        case 101...150: return .orange
        case 151...200: return .red
        default: return .purple
        }
    }
}
