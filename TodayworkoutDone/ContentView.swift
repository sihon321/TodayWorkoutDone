//
//  ContentView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/11/14.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        HomeView(
            store: Store(
                initialState: HomeReducer.State(myRoutine: Shared(MyRoutine()))
            ) {
                HomeReducer()
            }
        )
        .ignoresSafeArea(.all, edges: .bottom)
    }
}
