import SwiftUI

struct SevenDayForecastView: View {
    let forecasts: [DailyForecast]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(forecasts) { forecast in
                DailyForecastRow(
                    forecast: forecast,
                    isToday: Formatters.isToday(forecast.date)
                )
                if forecast.id != forecasts.last?.id {
                    Divider()
                        .overlay(Color.white.opacity(0.1))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
