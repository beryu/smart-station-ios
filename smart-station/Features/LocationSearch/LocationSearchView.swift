import ComposableArchitecture
import SwiftUI

struct LocationSearchView: View {
    @Bindable var store: StoreOf<LocationSearchFeature>

    var body: some View {
        NavigationStack {
            List {
                if store.isSearching {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }

                ForEach(store.results) { result in
                    Button {
                        store.send(.resultTapped(result))
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.name)
                                .font(.headline)
                            if let admin1 = result.admin1, let country = result.country {
                                Text("\(admin1), \(country)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .searchable(
                text: $store.searchText.sending(\.searchTextChanged),
                prompt: "都市名を検索..."
            )
            .navigationTitle("地域を追加")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
