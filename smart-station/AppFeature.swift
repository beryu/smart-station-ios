import ComposableArchitecture
import Foundation
import SwiftData
import SwiftUI

@Reducer
nonisolated struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var items: [Item] = []
    }

    enum Action {
        case addItemButtonTapped
        case deleteItems(IndexSet)
        case onAppear
        case itemsLoaded([Item])
    }

    @Dependency(\.modelContainer) var modelContainer

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addItemButtonTapped:
                let newItem = Item(timestamp: Date())
                state.items.append(newItem)
                return .run { _ in
                    let context = ModelContext(modelContainer)
                    context.insert(newItem)
                    try context.save()
                }

            case let .deleteItems(offsets):
                let itemsToDelete = offsets.map { state.items[$0] }
                state.items.remove(atOffsets: offsets)
                return .run { _ in
                    let context = ModelContext(modelContainer)
                    for item in itemsToDelete {
                        let id = item.persistentModelID
                        if let stored = context.model(for: id) as? Item {
                            context.delete(stored)
                        }
                    }
                    try context.save()
                }

            case .onAppear:
                return .run { send in
                    let context = ModelContext(modelContainer)
                    let descriptor = FetchDescriptor<Item>(
                        sortBy: [SortDescriptor(\.timestamp, order: .forward)]
                    )
                    let items = try context.fetch(descriptor)
                    await send(.itemsLoaded(items))
                }

            case let .itemsLoaded(items):
                state.items = items
                return .none
            }
        }
    }
}
