//
//  MainContentView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/05.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MainContentFeature {
    enum MainContentType: String, Identifiable {
        case stepCount
        case workoutTime
        case energyBurn
        
        var id: String { self.rawValue }
    }
    
    @ObservableState
    struct State: Equatable {
        var dataList: [MainContentType] = []
        var weeklyChart = WeeklyChart.State()
    }
    
    enum Action {
        case requstAuthrization
        case reloadData
        
        case weeklyChart(WeeklyChart.Action)
    }
    
    @Dependency(\.healthKitManager) private var healthKitManager
    
    var body: some Reducer<State, Action> {
        Scope(state: \.weeklyChart, action: \.weeklyChart) {
            WeeklyChart()
        }
        Reduce { state, action in
            switch action {
            case .requstAuthrization:
                return .run { send in
                    do {
                        let _ = try await healthKitManager.authorizeHealthKit(
                            typesToShare: [],
                            typesToRead: [
                                .quantityType(forIdentifier: .stepCount)!,
                                .quantityType(forIdentifier: .activeEnergyBurned)!,
                                .quantityType(forIdentifier: .appleExerciseTime)!
                            ]
                        )
                        await send(.reloadData)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            case .reloadData:
                state.dataList = [.stepCount, .workoutTime, .energyBurn]
                return .send(.weeklyChart(.fetchDailyActiveEnergyBurnes))
            case .weeklyChart:
                return .none
            }
        }
    }
}

struct MainContentView: View {
    @Bindable var store: StoreOf<MainContentFeature>
    @ObservedObject var viewStore: ViewStoreOf<MainContentFeature>
    private let gridLayout = Array(repeating: GridItem(.flexible()),
                                   count: 2)

    init(store: StoreOf<MainContentFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack {
            WeeklyChartView(
                store: store.scope(state: \.weeklyChart, action: \.weeklyChart)
            )
            Spacer(minLength: 15)
            LazyVGrid(columns: gridLayout, spacing: 10) {
                ForEach(viewStore.dataList) { data in
                    NavigationLink {
                        MainContentDetailView(store: Store(
                            initialState: MainContentDetailViewReducer.State(contentType: data)
                        ) {
                            MainContentDetailViewReducer()
                        })
                    } label: {
                        MainContentSubView(store: Store(initialState: MainSubContentFeature.State(type: data)) {
                            MainSubContentFeature()
                        })
                    }
                }
            }
            .onAppear {
                viewStore.send(.requstAuthrization)
            }
        }
        .padding([.leading, .trailing], 15)
    }
}
