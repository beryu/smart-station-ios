import ComposableArchitecture
import Foundation
import CoreLocation

@Reducer
nonisolated struct DashboardFeature {
    @ObservableState
    struct State: Equatable {
        var clock = ClockFeature.State()
        @Presents var locationSearch: LocationSearchFeature.State?

        // Location
        var currentLocation: SavedLocation?
        var additionalLocations: [SavedLocation] = []
        var selectedLocationID: SavedLocation.ID?
        var locationName: String = "取得中..."

        // Weather data
        var weatherResponse: WeatherResponse?
        var airQualityResponse: AirQualityResponse?
        var isLoading: Bool = false
        var errorMessage: String?

        // Computed properties
        var currentTemperature: Double? { weatherResponse?.current.temperature2m }
        var currentHumidity: Int? { weatherResponse?.current.relativeHumidity2m }
        var todayHigh: Double? { weatherResponse?.daily.temperature2mMax.first }
        var todayLow: Double? { weatherResponse?.daily.temperature2mMin.first }
        var sunrise: String? { weatherResponse?.daily.sunrise.first }
        var sunset: String? { weatherResponse?.daily.sunset.first }

        var currentWeatherCode: WMOWeatherCode? {
            guard let code = weatherResponse?.current.weatherCode else { return nil }
            return WMOWeatherCode(rawValue: code)
        }

        var currentVisibility: Double? {
            guard let hourly = weatherResponse?.hourly,
                  let index = closestHourlyIndex(times: hourly.time) else { return nil }
            return hourly.visibility[index]
        }

        var currentAQI: Int? { airQualityResponse?.current?.usAqi }
        var currentPM25: Double? { airQualityResponse?.current?.pm25 }

        var dailyForecasts: [DailyForecast] {
            guard let daily = weatherResponse?.daily else { return [] }
            return (0..<daily.time.count).map { i in
                DailyForecast(
                    date: daily.time[i],
                    weatherCode: daily.weatherCode[i],
                    highTemp: daily.temperature2mMax[i],
                    lowTemp: daily.temperature2mMin[i],
                    precipitationProbability: daily.precipitationProbabilityMax[i],
                    precipitationSum: daily.precipitationSum[i]
                )
            }
        }

        var activeLocation: SavedLocation? {
            if let selectedID = selectedLocationID {
                return additionalLocations.first { $0.id == selectedID }
            }
            return currentLocation
        }

        private func closestHourlyIndex(times: [String]) -> Int? {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
            let now = Date()
            var bestIndex: Int?
            var bestDiff: TimeInterval = .infinity
            for (i, timeStr) in times.enumerated() {
                guard let date = formatter.date(from: timeStr) else { continue }
                let diff = abs(date.timeIntervalSince(now))
                if diff < bestDiff {
                    bestDiff = diff
                    bestIndex = i
                }
            }
            return bestIndex
        }
    }

    enum Action {
        case onAppear
        case onDisappear
        case clock(ClockFeature.Action)
        case locationSearch(PresentationAction<LocationSearchFeature.Action>)
        case locationResolved(latitude: Double, longitude: Double)
        case locationNameResolved(String)
        case locationPermissionDenied
        case fetchWeatherData
        case weatherDataResponse(Result<WeatherResponse, Error>)
        case airQualityDataResponse(Result<AirQualityResponse, Error>)
        case autoRefreshTimerTicked
        case addLocationButtonTapped
        case selectLocation(SavedLocation.ID?)
    }

    @Dependency(\.weatherClient) var weatherClient
    @Dependency(\.airQualityClient) var airQualityClient
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.continuousClock) var continuousClock

    private enum CancelID {
        case autoRefresh
        case weatherFetch
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.clock, action: \.clock) {
            ClockFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .merge(
                    .send(.clock(.start)),
                    .run { send in
                        let coordinate = try await locationClient.requestLocation()
                        await send(.locationResolved(
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude
                        ))
                    } catch: { _, send in
                        await send(.locationPermissionDenied)
                    },
                    .run { send in
                        for await _ in continuousClock.timer(interval: .seconds(900)) {
                            await send(.autoRefreshTimerTicked)
                        }
                    }
                    .cancellable(id: CancelID.autoRefresh)
                )

            case let .locationResolved(latitude, longitude):
                let location = SavedLocation(
                    name: "Current Location",
                    latitude: latitude,
                    longitude: longitude,
                    isCurrentLocation: true
                )
                state.currentLocation = location
                return .merge(
                    .send(.fetchWeatherData),
                    .run { send in
                        let name = try await locationClient.reverseGeocode(latitude, longitude)
                        await send(.locationNameResolved(name))
                    }
                )

            case let .locationNameResolved(name):
                state.locationName = name
                state.currentLocation?.name = name
                return .none

            case .locationPermissionDenied:
                // Fall back to Tokyo so the app is always usable
                let fallbackLat = 35.6762
                let fallbackLon = 139.6503
                let fallback = SavedLocation(
                    name: "東京",
                    latitude: fallbackLat,
                    longitude: fallbackLon,
                    isCurrentLocation: false
                )
                state.currentLocation = fallback
                state.locationName = "東京（位置情報なし）"
                return .send(.fetchWeatherData)

            case .fetchWeatherData:
                guard let location = state.activeLocation else {
                    state.errorMessage = "位置情報がありません"
                    return .none
                }
                state.isLoading = true
                state.errorMessage = nil
                let lat = location.latitude
                let lon = location.longitude
                return .merge(
                    .run { send in
                        let result = try await weatherClient.fetchWeather(lat, lon)
                        await send(.weatherDataResponse(.success(result)))
                    } catch: { error, send in
                        await send(.weatherDataResponse(.failure(error)))
                    },
                    .run { send in
                        let result = try await airQualityClient.fetchAirQuality(lat, lon)
                        await send(.airQualityDataResponse(.success(result)))
                    } catch: { error, send in
                        await send(.airQualityDataResponse(.failure(error)))
                    }
                )
                .cancellable(id: CancelID.weatherFetch)

            case let .weatherDataResponse(.success(response)):
                state.weatherResponse = response
                state.isLoading = false
                return .none

            case let .weatherDataResponse(.failure(error)):
                state.errorMessage = error.localizedDescription
                state.isLoading = false
                return .none

            case let .airQualityDataResponse(.success(response)):
                state.airQualityResponse = response
                return .none

            case .airQualityDataResponse(.failure):
                return .none

            case .autoRefreshTimerTicked:
                return .send(.fetchWeatherData)

            case .addLocationButtonTapped:
                state.locationSearch = LocationSearchFeature.State()
                return .none

            case let .locationSearch(.presented(.delegate(.locationSelected(result)))):
                let saved = SavedLocation(
                    name: result.name,
                    latitude: result.latitude,
                    longitude: result.longitude
                )
                state.additionalLocations.append(saved)
                state.locationSearch = nil
                return .none

            case .locationSearch:
                return .none

            case let .selectLocation(id):
                state.selectedLocationID = id
                if let loc = state.activeLocation {
                    state.locationName = loc.name
                }
                return .send(.fetchWeatherData)

            case .onDisappear:
                return .merge(
                    .cancel(id: CancelID.autoRefresh),
                    .send(.clock(.stop))
                )

            case .clock:
                return .none
            }
        }
        .ifLet(\.$locationSearch, action: \.locationSearch) {
            LocationSearchFeature()
        }
    }
}
