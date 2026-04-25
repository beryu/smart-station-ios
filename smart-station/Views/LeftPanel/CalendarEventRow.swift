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
        HStack(spacing: 4) {
          if !Calendar.current.isDateInToday(event.startDate) {
            Text(Self.dateFormatter.string(from: event.startDate))
              .font(.callout.bold())
              .foregroundStyle(.primary)
          }
          if event.isAllDay {
            let endDay = Calendar.current.date(byAdding: .day, value: -1, to: event.endDate) ?? event.endDate
            if Calendar.current.isDate(event.startDate, inSameDayAs: endDay) {
              Text("終日")
                .font(.caption.bold())
                .foregroundStyle(.cyan)
            } else {
              Text("終日 〜\(Self.dateFormatter.string(from: endDay))")
                .font(.caption.bold())
                .foregroundStyle(.cyan)
            }
          } else {
            Text("\(Self.timeFormatter.string(from: event.startDate))–\(Self.timeFormatter.string(from: event.endDate))")
              .font(.callout.bold().monospacedDigit())
              .foregroundStyle(.primary)
          }
        }
        
        Text(isMasked ? "●●●●●●" : event.title)
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(2)
        
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


