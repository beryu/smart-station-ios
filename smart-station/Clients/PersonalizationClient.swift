import ComposableArchitecture
import Foundation
import FoundationModels

@DependencyClient
struct PersonalizationClient: Sendable {
    var rankArticles: @Sendable (
        _ articles: [NewsArticle],
        _ ratingHistory: [ArticleRatingEntry]
    ) async throws -> [NewsArticle]
    var isAvailable: @Sendable () -> Bool = { false }
}

extension PersonalizationClient: DependencyKey {
    static let liveValue = PersonalizationClient(
        rankArticles: { articles, ratingHistory in
            guard !ratingHistory.isEmpty else {
                return articles.sorted { $0.publishedAt > $1.publishedAt }
            }

            let model = SystemLanguageModel.default
            guard model.availability == .available else {
                return articles.sorted { $0.publishedAt > $1.publishedAt }
            }

            // Build compact preference summary
            let goodEntries = ratingHistory.filter { $0.rating == .good }
            let badEntries = ratingHistory.filter { $0.rating == .bad }

            let goodSources = Set(goodEntries.map(\.articleSource))
                .prefix(10).joined(separator: ", ")
            let badSources = Set(badEntries.map(\.articleSource))
                .prefix(5).joined(separator: ", ")
            let goodTitles = goodEntries.prefix(15)
                .map(\.articleTitle).joined(separator: "; ")
            let badTitles = badEntries.prefix(8)
                .map(\.articleTitle).joined(separator: "; ")

            // Build article list (index + source + title only to save tokens)
            let articleList = articles.enumerated().map { i, a in
                "\(i): [\(a.source)] \(a.title)"
            }.joined(separator: "\n")

            let instructions = Instructions("""
            You are a news personalization engine. Score articles based on user preferences.
            User prefers sources/topics similar to: \(goodSources)
            User dislikes sources/topics similar to: \(badSources)
            Recently liked headlines: \(goodTitles)
            Recently disliked headlines: \(badTitles)
            """)

            let session = LanguageModelSession(instructions: instructions)

            let response = try await session.respond(
                to: """
                Rank these articles by relevance to user preferences.
                Assign each a score from 0-100.
                Articles:
                \(articleList)
                """,
                generating: ArticleRelevanceScores.self
            )

            let scores = response.content.scores
            let scoreMap = Dictionary(
                scores.map { ($0.index, $0.relevanceScore) },
                uniquingKeysWith: { first, _ in first }
            )

            return articles.enumerated()
                .sorted { lhs, rhs in
                    let lScore = scoreMap[lhs.offset] ?? 50
                    let rScore = scoreMap[rhs.offset] ?? 50
                    if lScore != rScore { return lScore > rScore }
                    return lhs.element.publishedAt > rhs.element.publishedAt
                }
                .map(\.element)
        },
        isAvailable: {
            SystemLanguageModel.default.availability == .available
        }
    )
}

extension DependencyValues {
    var personalizationClient: PersonalizationClient {
        get { self[PersonalizationClient.self] }
        set { self[PersonalizationClient.self] = newValue }
    }
}
