import Foundation

nonisolated struct SavedLocation: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var isCurrentLocation: Bool

    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        isCurrentLocation: Bool = false
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isCurrentLocation = isCurrentLocation
    }
}
