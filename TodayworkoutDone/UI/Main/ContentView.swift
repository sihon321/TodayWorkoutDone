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
        GeometryReader { proxy in
            let bottomEdge = proxy.safeAreaInsets.bottom
            
            HomeView(
                store: Store(
                    initialState: HomeReducer.State(
                        bottomEdge: bottomEdge == 0 ? 15 : bottomEdge
                    )) {
                        HomeReducer()
                    })
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
