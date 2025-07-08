//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import Dependencies
import ComposableArchitecture
import SwiftData

@Reducer
struct WorkoutReducer {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        var myRoutine: MyRoutineState
        var keyword: String = ""
        var categories: [WorkoutCategoryState] = []
        
        var myRoutineReducer = MyRoutineReducer.State()
        var workoutCategory = WorkoutCategoryReducer.State()
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        
        case search(keyword: String)
        case dismiss

        case getCategories
        case updateCategories([WorkoutCategoryState])
        case filteredCategories([WorkoutCategoryState])
        case getMyRoutines
        case fetchMyRoutines([MyRoutineState])
        
        case tappedDone(MyRoutineState)
        case createMakeWorkoutView(routines: [RoutineState], isEdit: Bool)
        case updateMakeWorkoutView(myRoutine: MyRoutineState, isEdit: Bool)
        
        case myRoutineReducer(MyRoutineReducer.Action)
        case workoutCategory(WorkoutCategoryReducer.Action)
        
        var description: String {
            return "\(self)"
        }
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case makeWorkoutView(MakeWorkoutReducer)
        case alert(AlertState<Alert>)
        
        enum Alert: Equatable {
            case tappedMyRoutineStart(MyRoutineState)
        }
    }
    
    @Dependency(\.myRoutineData) var myRoutineContext
    @Dependency(\.categoryAPI) var categoryRepository
    @Dependency(\.workoutAPI) var workoutRepository
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Scope(state: \.myRoutineReducer, action: \.myRoutineReducer) {
            MyRoutineReducer()
        }
        Scope(state: \.workoutCategory, action: \.workoutCategory) {
            WorkoutCategoryReducer()
        }
        Reduce { state, action in
            switch action {
            case .search(let keyword):
                state.keyword = keyword
                if keyword.isEmpty {
                    return .send(.filteredCategories(state.categories))
                } else {
                    let filteredCategories = state.categories.filter { $0.name.hasPrefix(keyword) }
                    return .send(.filteredCategories(filteredCategories))
                }
            case .dismiss:
                return .run { _ in
                    await dismiss()
                }
            case .getCategories:
                return .run { send in
                    let categories = categoryRepository.loadCategories()
                    await send(.updateCategories(categories))
                }
            case .updateCategories(let categories):
                state.categories = categories
                return .send(.filteredCategories(categories))
                
            case .filteredCategories(let categories):
                state.workoutCategory.workoutList = IdentifiedArrayOf(
                    uniqueElements: categories.compactMap {
                        WorkoutListReducer.State(isAddWorkoutPresented: false,
                                                 routines: state.myRoutine.routines,
                                                 category: $0)
                    }
                )
                return .none
            case .getMyRoutines:
                return .run { send in
                    let myRoutines = try myRoutineContext.fetchAll()
                        .compactMap { MyRoutineState(model: $0) }
                    await send(.fetchMyRoutines(myRoutines))
                }
                
            case .fetchMyRoutines(let myRoutines):
                state.myRoutineReducer.myRoutineSubview = IdentifiedArrayOf(
                    uniqueElements: myRoutines.compactMap {
                        MyRoutineSubviewReducer.State(myRoutine: $0)
                    }
                )
                return .none
                
            case .tappedDone:
                return .send(.dismiss)
                
            case let .createMakeWorkoutView(routines, isEdit):
                @Dependency(\.routineData.fetch) var fetch
                var routines = routines
                for (index, routine) in routines.enumerated() {
                    var descriptor = FetchDescriptor<Routine>(
                        predicate: #Predicate {
                            $0.workout.name == routine.workout.name
                        },
                        sortBy: [SortDescriptor(\.endDate, order: .reverse)]
                    )
                    descriptor.fetchLimit = 1
                    do {
                        if let prevRoutine = try fetch(descriptor).first {
                            for (setIndex, prevSet) in prevRoutine.sets.enumerated() where setIndex < routine.sets.count {
                                routines[index].sets[setIndex].prevReps = prevSet.prevReps
                                routines[index].sets[setIndex].prevWeight = prevSet.prevWeight
                                routines[index].sets[setIndex].prevDuration = prevSet.prevDuration
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                state.destination = .makeWorkoutView(MakeWorkoutReducer.State(
                    myRoutine: MyRoutineState(routines: routines),
                    isEdit: isEdit
                ))
                return .none
            case let .updateMakeWorkoutView(myRoutine, isEdit):
                state.destination = .makeWorkoutView(MakeWorkoutReducer.State(
                    myRoutine: myRoutine,
                    isEdit: isEdit
                ))
                return .none
            case .destination(.presented(.alert(.tappedMyRoutineStart(let myRoutine)))):
                return .run { send in
                    await send(.tappedDone(myRoutine))
                }
            case .destination(.presented(.makeWorkoutView(.save))):
                return .send(.getMyRoutines)
                
            case .destination:
                return .none

            // MARK: - myRoutine
            case let .myRoutineReducer(action):
                switch action {
                case let .touchedMyRoutine(selectedMyRoutine):
                    state.destination = .alert(.startMyRoutine(selectedMyRoutine))
                    return .none
                case .touchedMakeRoutine:
                    return .send(.createMakeWorkoutView(routines: [], isEdit: true))
                case let .myRoutineSubview(action):
                    switch action {
                    case let .element(_, action):
                        switch action {
                        case let .touchedEditMode(myRoutine):
                            return .send(.updateMakeWorkoutView(myRoutine: myRoutine, isEdit: true))
                        case let .touchedDelete(myRoutine):
                            if let id = myRoutine.persistentModelID {
                                return .run { send in
                                    let descriptor = FetchDescriptor<MyRoutine>(
                                        predicate: #Predicate { $0.persistentModelID == id }
                                    )
                                    if let routineToDelete = try myRoutineContext.fetch(descriptor).first {
                                        try myRoutineContext.delete(routineToDelete)
                                        try myRoutineContext.save()
                                    }
                                    
                                    await send(.getMyRoutines)
                                }
                            } else {
                                return .none
                            }
                        case .touchedMyRoutine(_):
                            return .none
                        }
                    }
                }
                
            // MARK: - workoutList
            case let .workoutCategory(action):
                switch action {
                case let .workoutList(.element(categoryId, .sortedWorkoutSection(.element(sectionId, .workoutListSubview(.element(rowId, .didTapped)))))):
                    if let categoryIndex = state.workoutCategory
                        .workoutList
                        .firstIndex(where: { $0.id == categoryId }) {
                        if let sectionIndex = state.workoutCategory
                            .workoutList[categoryIndex]
                            .soretedWorkoutSection
                            .firstIndex(where: { $0.id == sectionId }) {
                            if let rowIndex = state.workoutCategory
                                .workoutList[categoryIndex]
                                .soretedWorkoutSection[sectionIndex]
                                .workoutListSubview
                                .firstIndex(where: { $0.id == rowId }) {
                                let workout = state.workoutCategory.workoutList[categoryIndex]
                                    .soretedWorkoutSection[sectionIndex]
                                    .workoutListSubview[rowIndex]
                                    .workout

                                if workout.isSelected {
                                    state.myRoutine.routines.append(RoutineState(workout: workout))
                                    for index in 0..<state.workoutCategory.workoutList.count {
                                        state.workoutCategory.workoutList[index].routines.append(RoutineState(workout: workout))
                                    }
                                } else {
                                    state.myRoutine.routines.removeAll { $0.workout.name == workout.name }
                                    for index in 0..<state.workoutCategory.workoutList.count {
                                        state.workoutCategory.workoutList[index].routines.removeAll { $0.workout.name == workout.name }
                                    }
                                }
                            }
                        }
                    }

                    return .none
                case let .workoutList(.element(_, .createMakeWorkoutView(routines, isEdit))):
                    return .send(.createMakeWorkoutView(routines: routines, isEdit: isEdit))
                default:
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination) {
          Destination.body
        }
    }
}

struct WorkoutView: View {
    @Bindable var store: StoreOf<WorkoutReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkoutReducer>
    
    init(store: StoreOf<WorkoutReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    MyRoutineView(
                        store: store.scope(state: \.myRoutineReducer,
                                           action: \.myRoutineReducer)
                    )
                    .padding(.top, 10)
                    
                    WorkoutCategoryView(
                        store: store.scope(state: \.workoutCategory,
                                           action: \.workoutCategory)
                    )
                    .padding(.top, 10)
                }
            }
            .background(Color.background)
            .navigationBarTitle("workout", displayMode: .inline)
            .workoutViewToolbar(store: store, viewStore: viewStore)
        }
        .searchable(text: viewStore.binding(
            get: { $0.keyword },
            send: { WorkoutReducer.Action.search(keyword: $0) }
        ))
        .fullScreenCover(
            item: $store.scope(state: \.destination?.makeWorkoutView,
                               action: \.destination.makeWorkoutView)
        ) { store in
            MakeWorkoutView(store: store)
        }
        .alert($store.scope(state: \.destination?.alert,
                            action: \.destination.alert))
        .onAppear {
            viewStore.send(.getMyRoutines)
            viewStore.send(.getCategories)
        }
        .tint(.todBlack)
    }
}

extension AlertState where Action == WorkoutReducer.Destination.Alert {
    static func startMyRoutine(_ myRoutine: MyRoutineState) -> Self {
        Self {
            TextState("루틴을 시작하겠습니까?")
        } actions: {
            ButtonState(action: .tappedMyRoutineStart(myRoutine)) {
                TextState("OK")
            }
            ButtonState() {
                TextState("Cancel")
            }
        } message: {
            let message = myRoutine.routines
                .map({ "\($0.workout.name)" })
                .joined(separator: "\n")
            return TextState(message)
        }
    }
}

private extension View {
    func workoutViewToolbar(
        store: StoreOf<WorkoutReducer>,
        viewStore: ViewStoreOf<WorkoutReducer>
    ) -> some View {
        return self.modifier(WorkoutViewToolbar(store: store,
                                                viewStore: viewStore))
    }
}

private struct WorkoutViewToolbar: ViewModifier {
    
    @Bindable var store: StoreOf<WorkoutReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkoutReducer>
    
    func body(content: Content) -> some View {
        return content
            .toolbar(content: {
                if !viewStore.myRoutine.routines.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewStore.send(.createMakeWorkoutView(routines: store.myRoutine.routines,
                                                                  isEdit: false))
                        }) {
                            let selectedWorkoutCount = viewStore.myRoutine.routines.count
                            Text("Done(\(selectedWorkoutCount))")
                                .foregroundStyle(Color.todBlack)
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        viewStore.send(.dismiss)
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.todBlack)
                    })
                }
            })
    }
}
