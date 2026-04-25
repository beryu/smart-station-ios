import ComposableArchitecture
import SwiftUI

struct CalendarEventsView: View {
    let store: StoreOf<CalendarEventsFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if store.permissionStatus == .denied || store.permissionStatus == .restricted {
                permissionDeniedView
            } else if store.isLoading && store.events.isEmpty {
                loadingView
            } else if let errorMessage = store.errorMessage {
                errorView(errorMessage)
            } else if store.filteredEvents.isEmpty && store.permissionStatus == .authorized {
                emptyView
            } else if !store.filteredEvents.isEmpty {
                eventsListView
            }
        }
    }

    private var permissionDeniedView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("カレンダーへのアクセスが\n許可されていません")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("設定を開く") {
                store.send(.openSettingsTapped)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.caption.bold())
            .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
            Text("予定を取得中...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(.orange)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("再試行") {
                store.send(.fetchEvents)
            }
            .font(.caption.bold())
            .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("今後の予定はありません")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var eventsListView: some View {
        VStack(spacing: 8) {
            ForEach(store.filteredEvents) { event in
                CalendarEventRow(
                    event: event,
                    isMasked: store.isMasked
                )
                if event.id != store.filteredEvents.last?.id {
                    Divider()
                        .overlay(Color.white.opacity(0.1))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
