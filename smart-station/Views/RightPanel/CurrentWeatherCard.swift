import SwiftUI

struct CurrentWeatherCard: View {
    let weatherCode: WMOWeatherCode?
    let temperature: Double?
    let apparentTemperature: Double?
    let highTemp: Double?
    let lowTemp: Double?

    var body: some View {
        VStack(spacing: 8) {
            if let code = weatherCode {
                Image(systemName: code.sfSymbolName)
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 56))

                Text(code.description)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            if let temp = temperature {
                Text(Formatters.temperature(temp))
                    .font(.system(size: 52, weight: .thin, design: .rounded))
            }

            if let apparent = apparentTemperature {
                Text("体感 \(Formatters.temperature(apparent))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Label(Formatters.temperature(highTemp), systemImage: "arrow.up")
                    .foregroundStyle(.red)
                Label(Formatters.temperature(lowTemp), systemImage: "arrow.down")
                    .foregroundStyle(.cyan)
            }
            .font(.callout.bold())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
