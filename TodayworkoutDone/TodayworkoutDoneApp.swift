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
    let environment = AppEnvironment.bootstrap()
    
    var body: some Scene {
        WindowGroup {
            ContentView(container: environment.container)
        }
        .modelContainer(SwiftDataConfigurationProvider.shared.container)
    }
}
