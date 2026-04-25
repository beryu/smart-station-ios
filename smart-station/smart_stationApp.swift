//
//  smart_stationApp.swift
//  smart-station
//
//  Created by Ryuta Kibe on 2026/04/25.
//

import ComposableArchitecture
import SwiftUI

@main
struct smart_stationApp: App {
  var body: some Scene {
    WindowGroup {
      DashboardView(
        store: Store(initialState: DashboardFeature.State()) {
          DashboardFeature()
        }
      )
    }
  }
}
