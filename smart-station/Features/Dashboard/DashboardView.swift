import ComposableArchitecture
import SwiftUI

struct DashboardView: View {
  @Bindable var store: StoreOf<DashboardFeature>

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [Color.theme.backgroundTop, Color.theme.backgroundBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      if store.isLoading && store.weatherResponse == nil {
        VStack(spacing: 16) {
          ProgressView()
            .scaleEffect(1.5)
          Text("天気情報を取得中...")
            .font(.headline)
            .foregroundStyle(.secondary)
        }
      } else if let error = store.errorMessage, store.weatherResponse == nil {
        VStack(spacing: 16) {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 48))
            .foregroundStyle(.yellow)
          Text(error)
            .font(.headline)
            .multilineTextAlignment(.center)
          Button {
            store.send(.addLocationButtonTapped)
          } label: {
            Label("地域を手動で追加", systemImage: "plus.circle.fill")
              .font(.headline)
              .padding()
              .background(.ultraThinMaterial, in: Capsule())
          }
        }
        .padding()
      } else {
        GeometryReader { geometry in
          HStack(spacing: 16) {
            LeftPanelView(store: store)

            CenterPanelView(store: store)

            RightPanelView(store: store)
          }
          .padding(.horizontal, 16)
        }
      }
    }
    .overlay(alignment: .topTrailing) {
      Button {
        store.send(.addLocationButtonTapped)
      } label: {
        Image(systemName: "plus.circle.fill")
          .font(.title2)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(.white)
      }
      .padding()
    }
    .onAppear { store.send(.onAppear) }
    .onDisappear { store.send(.onDisappear) }
    .sheet(item: $store.scope(state: \.locationSearch, action: \.locationSearch)) { searchStore in
      LocationSearchView(store: searchStore)
    }
    .preferredColorScheme(.dark)
  }
}
