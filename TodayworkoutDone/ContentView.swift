//
//  ContentView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/11/14.
//

import SwiftUI
import ComposableArchitecture
import Combine

@Reducer
struct ContentReducer {
    @ObservableState
    struct State: Equatable {
        var cancellable = Set<AnyCancellable>()
    }
    
    enum Action {
        case requestAuthorization
        case authoriazationResponse(Result<Bool, Error>)
    }
    
    @Dependency(\.healthKitManager) private var healthKitManager
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .requestAuthorization:
                healthKitManager.requestAuthorization()
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { _ in
                        
                    })
                    .store(in: &state.cancellable)
                return .none
            case .authoriazationResponse(let result):
                return .none
            }
        }
    }
}

struct ContentView: View {
    @Bindable var store: StoreOf<ContentReducer>
    
    init(store: StoreOf<ContentReducer>) {
        self.store = store
    }
    
    var body: some View {
        HomeView(
            store: Store(
                initialState: HomeReducer.State(myRoutine: Shared(MyRoutine()))
            ) {
                HomeReducer()
            }
        )
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
            store.send(.requestAuthorization)
        }
    }
}
