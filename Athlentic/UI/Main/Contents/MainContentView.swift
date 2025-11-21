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
        var subContentList: IdentifiedArrayOf<MainSubContentFeature.State> = []
        var weeklyChart = WeeklyChart.State()
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case requstAuthrization
        case reloadData
        
        case weeklyChart(WeeklyChart.Action)
        case subContentList(IdentifiedActionOf<MainSubContentFeature>)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable {
            case detail(MainContentDetailViewReducer.State)
        }
        
        enum Action {
            case detail(MainContentDetailViewReducer.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: \.detail, action: \.detail) {
                MainContentDetailViewReducer()
            }
        }
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
                state.subContentList = [
                    MainSubContentFeature.State(type: .stepCount),
                    MainSubContentFeature.State(type: .workoutTime),
                    MainSubContentFeature.State(type: .energyBurn)
                ]
                return .send(.weeklyChart(.fetchDailyActiveEnergyBurnes))
            case .weeklyChart:
                return .none
            case .subContentList:
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.subContentList, action: \.subContentList) {
            MainSubContentFeature()
        }
        .forEach(\.path, action: \.path) {
            Path()
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
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {
                WeeklyChartView(
                    store: store.scope(state: \.weeklyChart, action: \.weeklyChart)
                )
                Spacer(minLength: 15)
                LazyVGrid(columns: gridLayout, spacing: 10) {
                    ForEach(store.scope(state: \.subContentList, action: \.subContentList)) { childStore in
                        NavigationLink(
                            state: MainContentFeature.Path.State.detail(
                                MainContentDetailViewReducer.State(
                                    contentType: childStore.state.type
                                )
                            )
                        ) {
                            MainContentSubView(store: childStore)
                        }
                    }
                }
                .onAppear {
                    viewStore.send(.requstAuthrization)
                }
            }
            .padding([.leading, .trailing], 15)
        } destination: { store in
            switch store.state {
            case .detail:
                if let store = store.scope(state: \.detail, action: \.detail) {
                    MainContentDetailView(store: store)
                }
            }
        }
    }
}
