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
        let id: UUID
        let isAddWorkoutPresented: Bool
        let category: WorkoutCategoryState
        var workouts: [WorkoutState] = []
        var routines: [RoutineState] = []
        var keyword: String = ""
        var filters: [String] = []
        var soretedWorkoutSection: IdentifiedArrayOf<SortedWorkoutSectionReducer.State> = []
        
        var selectedTrainingType: TrainingType = .weight
        var trainingTypes: [TrainingType] = TrainingType.allCases
        
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
        
        init(isAddWorkoutPresented: Bool,
             routines: [RoutineState],
             category: WorkoutCategoryState) {
            self.id = UUID()
            self.isAddWorkoutPresented = isAddWorkoutPresented
            self.routines = routines
            self.category = category
        }
    }
    
    enum Action {
        case search(keyword: String)
        
        case getWorkouts(String)
        case updateWorkouts([WorkoutState])
        case filteredWorkouts([WorkoutState])
        
        case dismiss([RoutineState])
        case createMakeWorkoutView(routines: [RoutineState], isEdit: Bool)
        
        case sortedWorkoutSection(IdentifiedActionOf<SortedWorkoutSectionReducer>)
        
        case typeSelected(TrainingType)
    }
    
    enum TrainingType: String, CaseIterable, Identifiable {
        case weight, machines

        var id: Self { self }
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
                state.filters = Set(workouts.flatMap(\.target)).sorted()
                state.soretedWorkoutSection = IdentifiedArrayOf(
                    uniqueElements: state.filteredGroupedNames(workouts)
                        .enumerated()
                        .compactMap { index, element in
                            SortedWorkoutSectionReducer.State(
                                id: UUID(),
                                index: index,
                                key: element.key,
                                routines: state.routines,
                                workouts: element.value
                            )
                        })
                return .none
            case .dismiss:
                return .run { _ in
                    await self.dismiss()
                }
            case .createMakeWorkoutView:
                return .none
            case .sortedWorkoutSection:
                return .none
                
            case .typeSelected(let newType):
                state.selectedTrainingType = newType
                return .send(.getWorkouts(newType.rawValue))
            }
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
        let index: Int
        let key: String
        var routines: [RoutineState]
        var workouts: [WorkoutState]
        var workoutListSubview: IdentifiedArrayOf<WorkoutListSubviewReducer.State> = []
        
        init(id: UUID,
             index: Int,
             key: String,
             routines: [RoutineState],
             workouts: [WorkoutState]) {
            self.id = id
            self.index = index
            self.key = key
            self.routines = routines
            self.workouts = workouts
            for (index, value) in workouts.enumerated() {
                if routines.contains(where: { $0.workout.name == value.name }) {
                    self.workouts[index].isSelected = true
                }
            }
            self.workoutListSubview = IdentifiedArray(
                uniqueElements: self.workouts.compactMap {
                    WorkoutListSubviewReducer.State(
                        id: UUID(),
                        workout: $0
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
                    .font(.system(size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color.contentBackground)
                    .overlay(Divider(), alignment: .bottom)
                    .zIndex(1) // 항상 앞에 있도록 설정
            }
            ScrollView {
                VStack(spacing: 0) {
                    Picker("", selection: $store.selectedTrainingType.sending(\.typeSelected)) {
                        ForEach(store.trainingTypes, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    HorizontalFilterView(filters: viewStore.filters,
                                         selectedFilters: $selectedFilters)
                    ForEach(store.scope(state: \.soretedWorkoutSection,
                                        action: \.sortedWorkoutSection)) { sectionStore in
                        WorkoutListHeaderView(index: sectionStore.index,
                                              title: sectionStore.key,
                                              topHeaderIndex: $topHeaderIndex)
                        .padding(.horizontal, 15)
                        ForEach(sectionStore.scope(state: \.workoutListSubview,
                                                   action: \.workoutListSubview)) { rowStore in
                            if selectedFilters.isEmpty
                                || (selectedFilters.isEmpty == false
                                    && selectedFilters.contains(where: { rowStore.workout.target.contains($0) })) {
                                WorkoutListSubview(store: rowStore)
                                    .padding(.vertical, 3)
                                    .padding(.horizontal, 15)
                            }
                        }
                    }
                }
            }
            .background(Color.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !viewStore.routines.isEmpty {
                        Button(action: {
                            if viewStore.isAddWorkoutPresented {
                                viewStore.send(.dismiss(viewStore.routines))
                            } else {
                                viewStore.send(.createMakeWorkoutView(
                                    routines: viewStore.routines,
                                    isEdit: false)
                                )
                            }
                        }) {
                            let selectedWorkoutCount = viewStore.routines.count
                            Text("Done(\(selectedWorkoutCount))")
                                .foregroundStyle(Color.todBlack)
                        }
                    }
                }
            }
            .searchable(text: viewStore.binding(
                get: { $0.keyword },
                send: { WorkoutListReducer.Action.search(keyword: $0) }
            ))
            .navigationTitle(viewStore.category.name)
        }
        .onAppear {
            store.send(.getWorkouts(viewStore.category.classification))
        }
        .tint(.todBlack)
    }
}
