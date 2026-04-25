import Foundation
import FoundationModels

// MARK: - News Article

nonisolated struct NewsArticle: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let source: String
    let url: URL
    let publishedAt: Date
    var category: String?

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        source: String,
        url: URL,
        publishedAt: Date,
        category: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.source = source
        self.url = url
        self.publishedAt = publishedAt
        self.category = category
    }
}

// MARK: - User Rating

nonisolated enum ArticleRating: String, Codable, Equatable, Sendable {
    case good
    case bad
}

nonisolated struct ArticleRatingEntry: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    let articleID: UUID
    let articleTitle: String
    let articleSource: String
    let articleCategory: String?
    let rating: ArticleRating
    let ratedAt: Date

    init(
        id: UUID = UUID(),
        articleID: UUID,
        articleTitle: String,
        articleSource: String,
        articleCategory: String?,
        rating: ArticleRating,
        ratedAt: Date = Date()
    ) {
        self.id = id
        self.articleID = articleID
        self.articleTitle = articleTitle
        self.articleSource = articleSource
        self.articleCategory = articleCategory
        self.rating = rating
        self.ratedAt = ratedAt
    }
}

// MARK: - FoundationModels Generable Types

@Generable(description: "Relevance scores for news articles based on user preferences")
struct ArticleRelevanceScores {
    @Guide(description: "Array of scores, one per article, in the same order as the input articles")
    var scores: [ArticleScore]
}

@Generable(description: "A relevance score for a single article")
struct ArticleScore {
    @Guide(description: "The index of the article in the input list", .range(0...50))
    var index: Int

    @Guide(description: "Relevance score from 0 to 100, higher means more relevant to user preferences", .range(0...100))
    var relevanceScore: Int
}


