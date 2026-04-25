import ComposableArchitecture
import Foundation

struct RatingsClient: Sendable {
    var loadRatings: @Sendable () async throws -> [ArticleRatingEntry]
    var saveRating: @Sendable (_ entry: ArticleRatingEntry) async throws -> Void
    var removeRating: @Sendable (_ articleID: UUID) async throws -> Void
}

extension RatingsClient: DependencyKey {
    private static let storage = RatingsStorage()

    static let liveValue = RatingsClient(
        loadRatings: { try await storage.load() },
        saveRating: { entry in try await storage.save(entry) },
        removeRating: { articleID in try await storage.remove(articleID: articleID) }
    )

    static let testValue = RatingsClient(
        loadRatings: { [] },
        saveRating: { _ in },
        removeRating: { _ in }
    )
}

extension DependencyValues {
    var ratingsClient: RatingsClient {
        get { self[RatingsClient.self] }
        set { self[RatingsClient.self] = newValue }
    }
}

// MARK: - Thread-safe file storage

private actor RatingsStorage {
    private let fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("article_ratings.json")
    }()

    func load() throws -> [ArticleRatingEntry] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([ArticleRatingEntry].self, from: data)
    }

    func save(_ entry: ArticleRatingEntry) throws {
        var ratings = (try? load()) ?? []
        ratings.removeAll { $0.articleID == entry.articleID }
        ratings.append(entry)
        // Keep only last 200 ratings
        if ratings.count > 200 {
            ratings = Array(ratings.suffix(200))
        }
        let data = try JSONEncoder().encode(ratings)
        try data.write(to: fileURL, options: .atomic)
    }

    func remove(articleID: UUID) throws {
        var ratings = (try? load()) ?? []
        ratings.removeAll { $0.articleID == articleID }
        let data = try JSONEncoder().encode(ratings)
        try data.write(to: fileURL, options: .atomic)
    }
}
