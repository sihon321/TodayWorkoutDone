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
        
    }
    
    enum Action {
        case requestAuthorization
    }
    
    @Dependency(\.healthKitManager) private var healthKitManager
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .requestAuthorization:
                return .run { send in
                    do {
                        let isSuccess = try await healthKitManager.authorizeHealthKit(
                            typesToShare: [],
                            typesToRead: [
                                .quantityType(forIdentifier: .stepCount)!,
                                .quantityType(forIdentifier: .activeEnergyBurned)!,
                                .quantityType(forIdentifier: .appleExerciseTime)!,
                            ])
                        print("HealthKit authorization" + isSuccess.description)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
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
                initialState: HomeReducer.State()
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
