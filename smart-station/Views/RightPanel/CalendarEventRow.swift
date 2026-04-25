import SwiftUI

struct CalendarEventRow: View {
    let event: CalendarEvent
    let isMasked: Bool

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "H:mm"
        return f
    }()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "M/d"
        return f
    }()

    private var calendarColor: Color {
        Color(hex: event.calendarColorHex)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(calendarColor)
                .frame(width: 8, height: 8)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 2) {
                Text(isMasked ? "●●●●●●" : event.title)
                    .font(.callout.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    if !Calendar.current.isDateInToday(event.startDate) {
                        Text(Self.dateFormatter.string(from: event.startDate))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if event.isAllDay {
                        Text("終日")
                            .font(.caption.bold())
                            .foregroundStyle(.cyan)
                    } else {
                        Text("\(Self.timeFormatter.string(from: event.startDate))–\(Self.timeFormatter.string(from: event.endDate))")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }

                if let location = event.location, !location.isEmpty {
                    HStack(spacing: 2) {
                        Image(systemName: "mappin")
                            .font(.caption2)
                        Text(isMasked ? "●●●●" : location)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Color from Hex

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
