//
//  ContentView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/11/14.
//

import SwiftUI
import CoreData
import ComposableArchitecture

struct ContentView: View {
    @Environment(\.presentationMode) var presentationmode
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
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
            .inject(container)
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(container: .preview)
    }
}
