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
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: ContentReducer.State()) {
                ContentReducer()
            })
        }
        .modelContainer(SwiftDataConfigurationProvider.shared.container)
    }
}
