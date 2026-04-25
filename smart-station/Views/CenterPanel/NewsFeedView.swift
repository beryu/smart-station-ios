import ComposableArchitecture
import SwiftUI

struct NewsFeedView: View {
  let store: StoreOf<NewsFeature>
  
  var body: some View {
    Group {
      if store.isLoading && store.articles.isEmpty {
        VStack(spacing: 12) {
          ProgressView()
          Text("ニュースを取得中...")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
      } else if let error = store.errorMessage, store.articles.isEmpty {
        VStack(spacing: 12) {
          Image(systemName: "newspaper")
            .font(.system(size: 36))
            .foregroundStyle(.secondary)
          Text(error)
            .font(.caption)
            .foregroundStyle(.secondary)
          Button("再試行") {
            store.send(.refreshButtonTapped)
          }
          .font(.caption.bold())
        }
        .frame(maxHeight: .infinity)
      } else {
        ScrollView {
          LazyVStack(spacing: 12) {
            ForEach(store.articles) { article in
              NewsArticleCard(
                article: article,
                currentRating: store.currentRatings[article.id],
                onRate: { rating in
                  store.send(.rateArticle(
                    articleID: article.id,
                    rating: rating
                  ))
                },
                onTapArticle: {
                  store.send(.articleTapped(url: article.url))
                }
              )
            }
          }
          .padding(.vertical, 4)
        }
        .refreshable {
          await store.send(.refreshButtonTapped).finish()
        }
      }
    }
  }
}
