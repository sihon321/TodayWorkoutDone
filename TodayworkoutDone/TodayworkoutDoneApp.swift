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
    @State private var isLogin = false
    
    var body: some Scene {
        WindowGroup {
            if isActive {
                if isLogin {
                    ContentView(store: Store(initialState: ContentReducer.State()) {
                        ContentReducer()
                    })
                } else {
                    LoginView(isLogin: $isLogin)
                }
            } else {
                SplashView(isActive: $isActive)
            }
        }
        .modelContainer(SwiftDataConfigurationProvider.shared.container)
    }
}
