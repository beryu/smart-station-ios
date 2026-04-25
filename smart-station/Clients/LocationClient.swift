import ComposableArchitecture
import CoreLocation
import Foundation

@DependencyClient
nonisolated struct LocationClient: Sendable {
    var requestLocation: @Sendable () async throws -> CLLocationCoordinate2D
    var reverseGeocode: @Sendable (_ latitude: Double, _ longitude: Double) async throws -> String
}

extension LocationClient: DependencyKey {
    static let liveValue = LocationClient(
        requestLocation: {
            // Use CLLocationUpdate async stream — no delegate, no continuation needed.
            let updates = CLLocationUpdate.liveUpdates(.default)
            for try await update in updates {
                if let location = update.location {
                    return location.coordinate
                }
                if update.authorizationDenied || update.authorizationRestricted {
                    throw LocationError.permissionDenied
                }
                if update.insufficientlyInUse {
                    throw LocationError.permissionDenied
                }
            }
            throw LocationError.timeout
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

private nonisolated enum LocationError: LocalizedError {
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
