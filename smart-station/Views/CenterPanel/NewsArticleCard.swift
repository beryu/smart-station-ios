import SwiftUI

struct NewsArticleCard: View {
  let article: NewsArticle
  let currentRating: ArticleRating?
  let onRate: (ArticleRating) -> Void
  let onTapArticle: () -> Void
  
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      // Source + timestamp
      HStack {
        Text(article.source)
          .font(.caption.bold())
          .foregroundStyle(.blue)
        Spacer()
        Text(Formatters.relativeTime(from: article.publishedAt))
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
      
      // Title
      Text(article.title)
        .font(.subheadline.bold())
        .foregroundStyle(.primary)
        .lineLimit(3)
      
      // Description
      if !article.description.isEmpty {
        Text(article.description)
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(2)
      }
      
      // Rating buttons
      HStack(spacing: 16) {
        Spacer()
        Button {
          onRate(.good)
        } label: {
          HStack(spacing: 4) {
            Image(systemName: currentRating == .good
                  ? "hand.thumbsup.fill" : "hand.thumbsup")
            Text("Good")
              .font(.caption2)
          }
          .foregroundStyle(currentRating == .good ? .green : .secondary)
        }
        .buttonStyle(.plain)
        
        Button {
          onRate(.bad)
        } label: {
          HStack(spacing: 4) {
            Image(systemName: currentRating == .bad
                  ? "hand.thumbsdown.fill" : "hand.thumbsdown")
            Text("Bad")
              .font(.caption2)
          }
          .foregroundStyle(currentRating == .bad ? .red : .secondary)
        }
        .buttonStyle(.plain)
      }
    }
    .padding()
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    .contentShape(RoundedRectangle(cornerRadius: 12))
    .onTapGesture { onTapArticle() }
  }
}
