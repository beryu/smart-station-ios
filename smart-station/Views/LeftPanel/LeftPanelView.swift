import ComposableArchitecture
import SwiftUI

struct LeftPanelView: View {
  let store: StoreOf<DashboardFeature>

  var body: some View {
    VStack(spacing: 20) {
      // Location name
      HStack {
        Image(systemName: store.currentLocation?.isCurrentLocation == true ? "location.fill" : "mappin.circle.fill")
          .foregroundStyle(.blue)
        Text(store.locationName)
          .font(.title3.bold())
      }

      // Clock
      ClockView(store: store.scope(state: \.clock, action: \.clock))

      ScrollView {
        // Calendar Events
        HStack {
          Image(systemName: "calendar.badge.clock")
            .foregroundStyle(.blue)
          Text("今後の予定")
            .font(.title3.bold())
          Spacer()
          Button {
            store.send(.calendarEvents(.filterButtonTapped))
          } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
              .font(.callout)
              .foregroundColor(
                store.calendarEvents.excludedCalendarIDs.isEmpty
                  ? .secondary : .blue
              )
          }
          .buttonStyle(.plain)
          Button {
            store.send(.calendarEvents(.toggleMask))
          } label: {
            Image(systemName: store.calendarEvents.isMasked
                  ? "eye.slash.fill" : "eye.fill")
            .font(.callout)
            .foregroundStyle(store.calendarEvents.isMasked ? .orange : .secondary)
          }
          .buttonStyle(.plain)
        }
        .sheet(isPresented: Binding(
          get: { store.calendarEvents.isFilterSheetPresented },
          set: { newValue in
            if !newValue { store.send(.calendarEvents(.dismissFilter)) }
          }
        )) {
          CalendarFilterView(
            store: store.scope(state: \.calendarEvents, action: \.calendarEvents)
          )
        }

        CalendarEventsView(
          store: store.scope(state: \.calendarEvents, action: \.calendarEvents)
        )
      }
    }
  }
}
