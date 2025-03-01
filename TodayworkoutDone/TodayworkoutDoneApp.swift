//
//  TodayworkoutDoneApp.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/11/14.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct TodayworkoutDoneApp: App {
    @State private var isActive = false
    
    var body: some Scene {
        WindowGroup {
            if isActive {
                ContentView(store: Store(initialState: ContentReducer.State()) {
                    ContentReducer()
                })
            } else {
                SplashView(isActive: $isActive)
            }
        }
        .modelContainer(SwiftDataConfigurationProvider.shared.container)
    }
}
