import SwiftUI

struct DailyForecastRow: View {
    let forecast: DailyForecast
    let isToday: Bool

    var body: some View {
        HStack {
            Text(isToday ? "今日" : Formatters.dayName(from: forecast.date))
                .font(.callout.bold())
                .frame(width: 36, alignment: .leading)
                .foregroundStyle(isToday ? .yellow : .primary)

            if let code = WMOWeatherCode(rawValue: forecast.weatherCode) {
                Image(systemName: code.sfSymbolName)
                    .symbolRenderingMode(.multicolor)
                    .frame(width: 28)
            }

            if forecast.precipitationProbability > 0 {
                Text("\(forecast.precipitationProbability)%")
                    .font(.caption)
                    .foregroundStyle(.cyan)
                    .frame(width: 36)
            } else {
                Text("")
                    .frame(width: 36)
            }

            Spacer()

            Text(Formatters.temperatureShort(forecast.lowTemp))
                .foregroundStyle(.cyan)
                .frame(width: 36, alignment: .trailing)

            TemperatureBar(low: forecast.lowTemp, high: forecast.highTemp)
                .frame(width: 60, height: 4)

            Text(Formatters.temperatureShort(forecast.highTemp))
                .foregroundStyle(.orange)
                .frame(width: 36, alignment: .leading)
        }
        .font(.callout.monospacedDigit())
    }
}

struct TemperatureBar: View {
    let low: Double
    let high: Double

    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [.cyan, .yellow, .orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}
