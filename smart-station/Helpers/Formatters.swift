import Foundation

enum Formatters {
    static func temperature(_ value: Double?) -> String {
        guard let value else { return "--" }
        return "\(Int(round(value)))°"
    }

    static func temperatureShort(_ value: Double) -> String {
        "\(Int(round(value)))°"
    }

    static func percentage(_ value: Int?) -> String {
        guard let value else { return "--" }
        return "\(value)%"
    }

    static func visibility(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", meters / 1000)
        }
        return "\(Int(meters)) m"
    }

    static func windDirection(_ degrees: Double) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                          "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((degrees + 11.25).truncatingRemainder(dividingBy: 360) / 22.5) % 16
        return directions[index]
    }

    static func timeFromISO(_ isoString: String?) -> String {
        guard let isoString else { return "--:--" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
        guard let date = formatter.date(from: isoString) else { return isoString }
        let display = DateFormatter()
        display.dateFormat = "H:mm"
        return display.string(from: date)
    }

    static func dayName(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        let display = DateFormatter()
        display.locale = Locale(identifier: "ja_JP")
        display.dateFormat = "E"
        return display.string(from: date)
    }

    static func fullDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日 (E)"
        return formatter.string(from: date)
    }

    static func isToday(_ dateString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return false }
        return Calendar.current.isDateInToday(date)
    }

    static func relativeTime(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
