//
//  ContentView.swift
//  smart-station
//
//  Created by Ryuta Kibe on 2026/04/25.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(store.items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete { offsets in
                    store.send(.deleteItems(offsets), animation: .default)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        store.send(.addItemButtonTapped, animation: .default)
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        } detail: {
            Text("Select an item")
        }
    }
}

#Preview {
    ContentView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
