import ComposableArchitecture
import SwiftUI

struct CenterPanelView: View {
  let store: StoreOf<DashboardFeature>
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "newspaper.fill")
          .foregroundStyle(.blue)
        Text("ニュース")
          .font(.title3.bold())
        Spacer()
        if store.news.isPersonalizationAvailable {
          HStack(spacing: 4) {
            Image(systemName: "brain")
              .font(.caption2)
            Text("パーソナライズ")
              .font(.caption2)
          }
          .foregroundStyle(.green)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(.green.opacity(0.15), in: Capsule())
        }
      }
      
      NewsFeedView(
        store: store.scope(state: \.news, action: \.news)
      )
    }
    .onAppear {
      store.send(.news(.onAppear))
    }
  }
}
