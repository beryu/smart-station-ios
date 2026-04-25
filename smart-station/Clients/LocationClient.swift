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
            try await withThrowingTaskGroup(of: CLLocationCoordinate2D.self) { group in
                group.addTask {
                    try await LocationManager.shared.requestLocation()
                }
                group.addTask {
                    try await Task.sleep(for: .seconds(15))
                    throw LocationError.timeout
                }
                guard let result = try await group.next() else {
                    throw LocationError.timeout
                }
                group.cancelAll()
                return result
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

// MARK: - MainActor-isolated Location Manager

@MainActor
private final class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestLocation() async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let status = manager.authorizationStatus
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            default:
                resume(with: .failure(LocationError.permissionDenied))
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                guard self.continuation != nil else { return }
                manager.requestLocation()
            case .denied, .restricted:
                self.resume(with: .failure(LocationError.permissionDenied))
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor in
            self.resume(with: .success(location.coordinate))
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.resume(with: .failure(error))
        }
    }

    private func resume(with result: Result<CLLocationCoordinate2D, Error>) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(with: result)
    }
}

private enum LocationError: LocalizedError {
    case permissionDenied
    case timeout

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission was denied."
        case .timeout:
            return "Location request timed out."
        }
    }
}
