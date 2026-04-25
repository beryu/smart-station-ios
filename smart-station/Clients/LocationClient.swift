import ComposableArchitecture
import CoreLocation
import Foundation

@DependencyClient
struct LocationClient: Sendable {
    var requestLocation: @Sendable () async throws -> CLLocationCoordinate2D
    var reverseGeocode: @Sendable (_ latitude: Double, _ longitude: Double) async throws -> String
}

extension LocationClient: DependencyKey {
    static let liveValue = LocationClient(
        requestLocation: {
            try await withCheckedThrowingContinuation { continuation in
                let delegate = LocationDelegate(continuation: continuation)
                delegate.start()
            }
        },
        reverseGeocode: { latitude, longitude in
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let geocoder = CLGeocoder()
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.locality ?? placemarks.first?.name ?? "Unknown"
        }
    )
}

extension DependencyValues {
    var locationClient: LocationClient {
        get { self[LocationClient.self] }
        set { self[LocationClient.self] = newValue }
    }
}

// MARK: - CLLocationManager Delegate Bridge

private final class LocationDelegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    private let continuation: CheckedContinuation<CLLocationCoordinate2D, Error>
    private let manager = CLLocationManager()
    private var hasResumed = false

    init(continuation: CheckedContinuation<CLLocationCoordinate2D, Error>) {
        self.continuation = continuation
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func start() {
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            resume(with: .failure(LocationError.permissionDenied))
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            resume(with: .failure(LocationError.permissionDenied))
        default:
            break
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        resume(with: .success(location.coordinate))
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resume(with: .failure(error))
    }

    private func resume(with result: Result<CLLocationCoordinate2D, Error>) {
        guard !hasResumed else { return }
        hasResumed = true
        continuation.resume(with: result)
    }
}

private enum LocationError: LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission was denied."
        }
    }
}
