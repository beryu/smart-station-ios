import ComposableArchitecture
import SwiftUI

struct CalendarFilterView: View {
    let store: StoreOf<CalendarEventsFeature>

    var body: some View {
        NavigationStack {
            Group {
                if store.availableCalendars.isEmpty {
                    ProgressView()
                } else {
                    calendarList
                }
            }
            .navigationTitle("表示するカレンダー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        store.send(.dismissFilter)
                    }
                }
            }
        }
    }

    private var calendarList: some View {
        List {
            let calendars = store.availableCalendars
            let excluded = store.excludedCalendarIDs
            ForEach(calendars) { calendar in
                Button {
                    store.send(.toggleCalendar(calendar.id))
                } label: {
                    let isExcluded = excluded.contains(calendar.id)
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: calendar.colorHex))
                            .frame(width: 12, height: 12)

                        Text(calendar.title)
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: isExcluded ? "square" : "checkmark.square.fill")
                            .foregroundColor(isExcluded ? .secondary : .blue)
                            .font(.title3)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
