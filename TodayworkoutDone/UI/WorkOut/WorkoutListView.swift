//
//  WorkoutListView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI
import ComposableArchitecture
import Combine

@Reducer
struct WorkoutListReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        @Presents var destination: Destination.State?
        
        let id: UUID
        let isAddWorkoutPresented: Bool
        var myRoutine: MyRoutine
        let categoryName: String
        var categories: Categories
        var workouts: [Workout] = []
        var keyword: String = ""
        
        var groupedNames: [(key: String, value: [Workout])] {
            let filteredWorkout = workouts.filter { $0.name.hasPrefix(keyword) }
            let groupedDictionary = Dictionary(grouping: filteredWorkout,
                                               by: { extractFirstCharacter($0.name) })
            return groupedDictionary.sorted { $0.key < $1.key }
        }
        
        func extractFirstCharacter(_ name: String) -> String {
            guard let first = name.first else { return "#" }
            let unicode = first.unicodeScalars.first!.value

            if unicode >= 0xAC00, unicode <= 0xD7A3 {
                let index = (unicode - 0xAC00) / 28 / 21
                let chosungList = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
                return chosungList[Int(index)]
            }
            
            if first.isLetter {
                return String(first).uppercased()
            }

            return "#"
        }
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        
        case search(keyword: String)
        case updateMyRoutine(Workout)
        case makeWorkoutView([Routine])
        case getWorkouts(String)
        case updateWorkouts([Workout])
        case dismiss
        case appearMakeWorkout
        case createMakeWorkoutView(myRoutine: MyRoutine?, isEdit: Bool)
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case makeWorkoutView(MakeWorkoutReducer)
    }
    
    @Dependency(\.workoutAPI) var workoutRepository
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .search(let keyword):
                state.keyword = keyword
                return .none
            case let .updateMyRoutine(workout):
                if workout.isSelected {
                    state.myRoutine.routines.append(Routine(workouts: workout))
                } else {
                    state.myRoutine.routines.removeAll { $0.workout.name == workout.name }
                }
                return .none
            case let .getWorkouts(categoryName):
                return .run { send in
                    let workouts = workoutRepository.loadWorkouts(categoryName)
                    await send(.updateWorkouts(workouts))
                }
            case .updateWorkouts(let workouts):
                state.workouts = workouts
                return .none
            case .makeWorkoutView:
                return .send(.appearMakeWorkout)
            case .dismiss:
                return .run { _ in
                    await self.dismiss()
                }
            case .appearMakeWorkout:
                return .send(.createMakeWorkoutView(myRoutine: state.myRoutine,
                                                    isEdit: false))
            case let .createMakeWorkoutView(myRoutine, isEdit):
                state.destination = .makeWorkoutView(
                    MakeWorkoutReducer.State(
                        myRoutine: myRoutine ?? state.myRoutine,
                        categories: state.categories,
                        isEdit: isEdit
                    )
                )
                
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
    }
}

struct WorkoutListView: View {
    @Bindable var store: StoreOf<WorkoutListReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkoutListReducer>
    @State private var topHeaderIndex: Int? = nil
    private var filters: [String] = []
    @State private var selectedFilters: Set<String> = []
    
    init(store: StoreOf<WorkoutListReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        self.filters = Array(Set(store.workouts.compactMap(\.target))).sorted()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if let index = topHeaderIndex {
                Text(viewStore.groupedNames[index].key)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    .overlay(Divider(), alignment: .bottom)
                    .zIndex(1) // 항상 앞에 있도록 설정
            }
            ScrollView {
                VStack(spacing: 0) {
                    HorizontalFilterView(filters: filters,
                                         selectedFilters: $selectedFilters)
                        .padding(.horizontal)
                    ForEach(Array(viewStore.groupedNames.enumerated()), id: \.offset) { index, section in
                        StickyHeaderView(index: index,
                                         title: section.key,
                                         topHeaderIndex: $topHeaderIndex)
                        ForEach(section.value, id: \.self) { workouts in
                            if selectedFilters.isEmpty
                                || (selectedFilters.isEmpty == false
                                && selectedFilters.contains(where: { $0 == workouts.target })) {
                                WorkoutListSubview(store: store, workouts: workouts)
                                    .padding(.vertical, 3)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !viewStore.myRoutine.routines.isEmpty {
                        Button(action: {
                            if store.isAddWorkoutPresented {
                                store.send(.dismiss)
                            } else {
                                store.send(.makeWorkoutView(store.myRoutine.routines))
                            }
                        }) {
                            let selectedWorkoutCount = viewStore.myRoutine.routines.count
                            Text("Done(\(selectedWorkoutCount))")
                        }
                    }
                }
            }
            .searchable(text: viewStore.binding(
                get: { $0.keyword },
                send: { WorkoutListReducer.Action.search(keyword: $0) }
            ))
            .navigationTitle(viewStore.categoryName)
        }
        .onAppear {
            store.send(.getWorkouts(viewStore.categoryName))
        }
        .fullScreenCover(
            item: $store.scope(state: \.destination?.makeWorkoutView,
                               action: \.destination.makeWorkoutView)
        ) { store in
            MakeWorkoutView(store: store)
        }
    }
}
