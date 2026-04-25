import ComposableArchitecture
import Foundation

@Reducer
nonisolated struct NewsFeature {
    @ObservableState
    struct State: Equatable {
        var articles: [NewsArticle] = []
        var ratingHistory: [ArticleRatingEntry] = []
        var isLoading: Bool = false
        var errorMessage: String?
        var isPersonalizationAvailable: Bool = false
        var currentRatings: [UUID: ArticleRating] = [:]
    }

    enum Action {
        case onAppear
        case fetchNews
        case newsResponse(Result<[NewsArticle], Error>)
        case ratingsLoaded(Result<[ArticleRatingEntry], Error>)
        case rateArticle(articleID: UUID, rating: ArticleRating)
        case ratingSaved(Result<Void, Error>)
        case ratingRemoved(articleID: UUID)
        case articlesRanked(Result<[NewsArticle], Error>)
        case articleTapped(url: URL)
        case refreshButtonTapped
    }

    @Dependency(\.newsClient) var newsClient
    @Dependency(\.ratingsClient) var ratingsClient
    @Dependency(\.personalizationClient) var personalizationClient

    private enum CancelID {
        case newsFetch
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isPersonalizationAvailable = personalizationClient.isAvailable()
                return .merge(
                    .send(.fetchNews),
                    .run { send in
                        let ratings = try await ratingsClient.loadRatings()
                        await send(.ratingsLoaded(.success(ratings)))
                    } catch: { error, send in
                        await send(.ratingsLoaded(.failure(error)))
                    }
                )

            case .fetchNews:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    let articles = try await newsClient.fetchTopHeadlines()
                    await send(.newsResponse(.success(articles)))
                } catch: { error, send in
                    await send(.newsResponse(.failure(error)))
                }
                .cancellable(id: CancelID.newsFetch)

            case let .newsResponse(.success(articles)):
                state.articles = articles
                state.isLoading = false
                if !state.ratingHistory.isEmpty {
                    let history = state.ratingHistory
                    return .run { send in
                        let ranked = try await personalizationClient.rankArticles(articles, history)
                        await send(.articlesRanked(.success(ranked)))
                    } catch: { error, send in
                        await send(.articlesRanked(.failure(error)))
                    }
                }
                return .none

            case .newsResponse(.failure):
                state.isLoading = false
                state.errorMessage = "ニュースの取得に失敗しました"
                return .none

            case let .ratingsLoaded(.success(ratings)):
                state.ratingHistory = ratings
                for entry in ratings {
                    state.currentRatings[entry.articleID] = entry.rating
                }
                if !state.articles.isEmpty && !ratings.isEmpty {
                    let articles = state.articles
                    return .run { send in
                        let ranked = try await personalizationClient.rankArticles(articles, ratings)
                        await send(.articlesRanked(.success(ranked)))
                    } catch: { error, send in
                        await send(.articlesRanked(.failure(error)))
                    }
                }
                return .none

            case .ratingsLoaded(.failure):
                return .none

            case let .rateArticle(articleID, rating):
                if state.currentRatings[articleID] == rating {
                    state.currentRatings.removeValue(forKey: articleID)
                    return .run { send in
                        try await ratingsClient.removeRating(articleID)
                        await send(.ratingRemoved(articleID: articleID))
                    } catch: { _, _ in }
                } else {
                    state.currentRatings[articleID] = rating
                    guard let article = state.articles.first(where: { $0.id == articleID }) else {
                        return .none
                    }
                    let entry = ArticleRatingEntry(
                        articleID: articleID,
                        articleTitle: article.title,
                        articleSource: article.source,
                        articleCategory: article.category,
                        rating: rating
                    )
                    return .run { send in
                        try await ratingsClient.saveRating(entry)
                        await send(.ratingSaved(.success(())))
                    } catch: { error, send in
                        await send(.ratingSaved(.failure(error)))
                    }
                }

            case .ratingSaved(.success):
                return .none

            case .ratingSaved(.failure):
                return .none

            case let .ratingRemoved(articleID):
                state.ratingHistory.removeAll { $0.articleID == articleID }
                return .none

            case let .articlesRanked(.success(rankedArticles)):
                state.articles = rankedArticles
                return .none

            case .articlesRanked(.failure):
                return .none

            case .articleTapped:
                return .none

            case .refreshButtonTapped:
                return .send(.fetchNews)
            }
        }
    }
}
