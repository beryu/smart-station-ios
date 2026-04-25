import SwiftUI

struct SunriseSunsetView: View {
    let sunrise: String?
    let sunset: String?

    var body: some View {
        HStack(spacing: 32) {
            VStack(spacing: 4) {
                Image(systemName: "sunrise.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.title2)
                Text(Formatters.timeFromISO(sunrise))
                    .font(.callout.monospacedDigit())
            }
            VStack(spacing: 4) {
                Image(systemName: "sunset.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.title2)
                Text(Formatters.timeFromISO(sunset))
                    .font(.callout.monospacedDigit())
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
