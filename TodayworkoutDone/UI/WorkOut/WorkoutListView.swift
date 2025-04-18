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
        var myRoutine: MyRoutineState
        let categoryName: String
        var categories: [WorkoutCategoryState]
        var workouts: [WorkoutState] = []
        var keyword: String = ""
        var filters: [String] = []
        var soretedWorkoutSection: IdentifiedArrayOf<SortedWorkoutSectionReducer.State> = []
        
        var groupedNames: [(key: String, value: [WorkoutState])] {
            let groupedDictionary = Dictionary(grouping: workouts,
                                               by: { extractFirstCharacter($0.name) })
            return groupedDictionary.sorted { $0.key < $1.key }
        }
        
        func filteredGroupedNames(_ workouts: [WorkoutState]) -> [(key: String, value: [WorkoutState])] {
            let groupedDictionary = Dictionary(grouping: workouts,
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
        
        case getWorkouts(String)
        case updateWorkouts([WorkoutState])
        case filteredWorkouts([WorkoutState])
        
        case dismiss(MyRoutineState)
        case createMakeWorkoutView(myRoutine: MyRoutineState?, isEdit: Bool)
        
        case sortedWorkoutSection(IdentifiedActionOf<SortedWorkoutSectionReducer>)
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
                if keyword.isEmpty {
                    return .send(.filteredWorkouts(state.workouts))
                } else {
                    let filteredCategories = state.workouts.filter { $0.name.hasPrefix(keyword) }
                    return .send(.filteredWorkouts(filteredCategories))
                }
                
            case let .getWorkouts(categoryName):
                return .run { send in
                    let workouts = workoutRepository.loadWorkouts(categoryName)
                    await send(.updateWorkouts(workouts))
                }
            case .updateWorkouts(let workouts):
                state.workouts = workouts
                return .send(.filteredWorkouts(workouts))
                
            case .filteredWorkouts(let workouts):
                state.filters = Array(Set(workouts.compactMap(\.target))).sorted()
                state.soretedWorkoutSection = IdentifiedArrayOf(
                    uniqueElements: state.filteredGroupedNames(workouts)
                        .enumerated()
                        .compactMap { index, element in
                            SortedWorkoutSectionReducer.State(
                                id: UUID(),
                                myRoutine: state.myRoutine,
                                index: index,
                                key: element.key,
                                workouts: element.value
                            )
                        })
                return .none
            case .dismiss:
                return .run { _ in
                    await self.dismiss()
                }
            case let .createMakeWorkoutView(myRoutine, isEdit):
                state.destination = .makeWorkoutView(
                    MakeWorkoutReducer.State(
                        myRoutine: myRoutine ?? state.myRoutine,
                        isEdit: isEdit
                    )
                )
                
                return .none
            case .destination:
                return .none
            case let .sortedWorkoutSection(.element(sectionId, action)):
                switch action {
                case let .workoutListSubview(.element(rowId, action)):
                    switch action {
                    case .didTapped:
                        if let sectionIndex = state.soretedWorkoutSection
                            .firstIndex(where: { $0.id == sectionId }) {
                            if let rowIndex = state.soretedWorkoutSection[sectionIndex].workoutListSubview
                                .firstIndex(where: { $0.id == rowId }) {
                                let workout = state.soretedWorkoutSection[sectionIndex]
                                    .workoutListSubview[rowIndex]
                                    .workout

                                if workout.isSelected {
                                    state.myRoutine.routines.append(RoutineState(workout: workout))
                                } else {
                                    state.myRoutine.routines.removeAll { $0.workout.name == workout.name }
                                }
                            }
                        }

                        return .none
                    }
                }
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
        .forEach(\.soretedWorkoutSection, action: \.sortedWorkoutSection) {
            SortedWorkoutSectionReducer()
        }
    }
}

@Reducer
struct SortedWorkoutSectionReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        var myRoutine: MyRoutineState
        let index: Int
        let key: String
        var workouts: [WorkoutState]
        var workoutListSubview: IdentifiedArrayOf<WorkoutListSubviewReducer.State> = []
        
        init(id: UUID,
             myRoutine: MyRoutineState,
             index: Int,
             key: String,
             workouts: [WorkoutState]) {
            self.id = id
            self.myRoutine = myRoutine
            self.index = index
            self.key = key
            self.workouts = workouts
            self.workoutListSubview = IdentifiedArray(
                uniqueElements: workouts.compactMap {
                    WorkoutListSubviewReducer.State(
                        id: UUID(),
                        workout: $0,
                        myRoutine: myRoutine
                    )
                }
            )
        }
    }
    
    enum Action {
        case workoutListSubview(IdentifiedActionOf<WorkoutListSubviewReducer>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .workoutListSubview:
                return .none
            }
        }
        .forEach(\.workoutListSubview, action: \.workoutListSubview) {
            WorkoutListSubviewReducer()
        }
    }
}

struct WorkoutListView: View {
    @Bindable var store: StoreOf<WorkoutListReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkoutListReducer>
    @State private var topHeaderIndex: Int? = nil
    @State private var selectedFilters: Set<String> = []
    
    init(store: StoreOf<WorkoutListReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
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
                    HorizontalFilterView(filters: store.filters,
                                         selectedFilters: $selectedFilters)
                        .padding(.horizontal)
                    ForEach(store.scope(state: \.soretedWorkoutSection,
                                        action: \.sortedWorkoutSection)) { sectionStore in
                        StickyHeaderView(index: sectionStore.index,
                                         title: sectionStore.key,
                                         topHeaderIndex: $topHeaderIndex)
                        
                        ForEach(sectionStore.scope(state: \.workoutListSubview,
                                                   action: \.workoutListSubview)) { rowStore in
                            if selectedFilters.isEmpty
                                || (selectedFilters.isEmpty == false
                                    && selectedFilters.contains(where: { $0 == rowStore.workout.target })) {
                                WorkoutListSubview(store: rowStore)
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
                            if viewStore.isAddWorkoutPresented {
                                viewStore.send(.dismiss(viewStore.myRoutine))
                            } else {
                                viewStore.send(.createMakeWorkoutView(myRoutine: viewStore.myRoutine,
                                                                      isEdit: false))
                            }
                        }) {
                            let selectedWorkoutCount = viewStore.myRoutine.routines.count
                            Text("Done(\(selectedWorkoutCount))")
                                .foregroundStyle(.black)
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
