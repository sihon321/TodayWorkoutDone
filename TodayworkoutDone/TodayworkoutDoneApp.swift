//
//  TodayworkoutDoneApp.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/11/14.
//

import SwiftUI
import SwiftData

@main
struct TodayworkoutDoneApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(SwiftDataConfigurationProvider.shared.container)
    }
}
