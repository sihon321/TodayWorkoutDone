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
        @Shared var myRoutine: MyRoutine
        
        var workoutCategory: WorkoutCategoryReducer.State
        var myRoutineState = MyRoutineReducer.State()
        var makeWorkout: MakeWorkoutReducer.State?
        var workouts: [Workout] = []
        var hasLoaded = false
        var deletedSectionIndex: Int?
        var changedTypes: [Int: WorkoutsType] = [:]
        
        var isEmptySelectedWorkouts: Bool {
            var isEmpty = true
            for workouts in workouts {
                if workouts.isSelected {
                    isEmpty = false
                    break
                }
            }
            return isEmpty
        }
        var predicate: Predicate<MyRoutine> {
            return #Predicate {
                $0.id == myRoutine.id
            }
        }
        var sort: [SortDescriptor<MyRoutine>] {
            return [
                .init(\.name)
            ].compactMap { $0 }
        }
        var fetchDescriptor: FetchDescriptor<MyRoutine> {
            return .init(predicate: self.predicate, sortBy: self.sort)
        }
        mutating func refetch(_ myRoutine: MyRoutine) -> MyRoutine? {
            @Dependency(\.myRoutineData) var context
            if let routine = try? context.fetch(self.fetchDescriptor).first {
                self.myRoutine = routine
                return self.myRoutine
            }
            
            return nil
        }
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        
        case workoutCategory(WorkoutCategoryReducer.Action)
        case makeWorkout(MakeWorkoutReducer.Action)
        case myRoutineAction(MyRoutineReducer.Action)
        
        case search(keyword: String)
        case dismiss
        case hasLoaded
        case getMyRoutines
        case appearMakeWorkout
        case createMakeWorkoutView(myRoutine: MyRoutine?, isEdit: Bool)
        case fetchMyRoutines([MyRoutine])
        
        var description: String {
            return "\(self)"
        }
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case makeWorkoutView(MakeWorkoutReducer)
        case alert(AlertState<Alert>)
        
        enum Alert: Equatable {
            case tappedMyRoutineStart(MyRoutine)
        }
    }
    
    @Dependency(\.myRoutineData) var context
    @Dependency(\.categoryAPI) var categoryRepository
    @Dependency(\.workoutAPI) var workoutRepository
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .search(let keyword):
                state.workoutCategory.keyword = keyword
                return .none
            case .dismiss:
                state.destination = .none
                return .run { _ in
                    await self.dismiss()
                }
            case .hasLoaded:
                state.hasLoaded = true
                return .none
            case .appearMakeWorkout:
                let routines = state.workouts
                    .filter({ $0.isSelected })
                    .compactMap({
                        return Routine(workouts: $0)
                    })
                state.myRoutine.routines = routines
                return .run { @MainActor send in
                    send(.createMakeWorkoutView(myRoutine: nil,
                                                isEdit: false))
                }
            case let .createMakeWorkoutView(myRoutine, isEdit):
                let myRoutine = myRoutine ?? state.myRoutine
                state.makeWorkout = MakeWorkoutReducer.State(
                    myRoutine: Shared(myRoutine),
                    isEdit: isEdit,
                    addWorkoutCategory: AddWorkoutCategoryReducer.State(
                        myRoutine: Shared(myRoutine),
                        workoutList: WorkoutListReducer.State(myRoutine: Shared(myRoutine))
                    ),
                    workingOutSection:  IdentifiedArrayOf(
                        uniqueElements: myRoutine.routines.map {
                            WorkingOutSectionReducer.State(
                                routine: $0,
                                editMode: .active
                            )
                        }
                    )
                )
                
                if let makeWorkoutState = state.makeWorkout {
                    state.destination = .makeWorkoutView(makeWorkoutState)
                }
                
                return .none
            case .getMyRoutines:
                return .run { send in
                    let myRoutines = try context.fetchAll()
                    await send(.fetchMyRoutines(myRoutines))
                }
            case .fetchMyRoutines(let myRoutines):
                state.myRoutineState.myRoutines = myRoutines
                return .none
            case .destination(.presented(.alert(.tappedMyRoutineStart(let myRoutine)))):
                state.myRoutine.name = myRoutine.name
                state.myRoutine.routines = myRoutine.routines
                return .send(.makeWorkout(.tappedDone))
            case .destination:
                return .none
                
            // MARK: - workoutCategory
            case .workoutCategory(let action):
                switch action {
                case .setText(let keyword):
                    state.workoutCategory.keyword = keyword
                    return .none
                case .getCategories:
                    return .run { send in
                        let categories = categoryRepository.loadCategories()
                        await send(.workoutCategory(.updateCategories(categories)))
                    }
                case .updateCategories(let categories):
                    state.workoutCategory.categories = categories
                    return .none
                    
                    // MARK: - workoutList
                case .workoutList(let action):
                    switch action {
                    case let .getWorkouts(categoryName):
                        return .run { send in
                            let workouts = workoutRepository.loadWorkouts(categoryName)
                            await send(.workoutCategory(.workoutList(.updateWorkouts(workouts))))
                        }
                    case .updateWorkouts(let workouts):
                        state.workouts = workouts
                        state.workoutCategory.workoutList.workouts = workouts
                        return .none
                    case .makeWorkoutView:
                        return .send(.appearMakeWorkout)
                    }
                }
                
            // MARK: - makeWorkout
            case .makeWorkout(let action):
                switch action {
                case .dismiss:
                    state.destination = .none
                    return .none
                case .tappedDone:
                    state.destination = .none
                    state.myRoutine.isRunning = true
                    return .run { send in
                        await send(.dismiss)
                    }
                case .save(let myRoutine):
                    saveMyRoutine()
                    if let sectionIndex = state.deletedSectionIndex {
                        state.makeWorkout?.myRoutine
                            .routines.remove(at: sectionIndex)
                    }
                    if state.changedTypes.isEmpty == false {
                        for (index, type) in state.changedTypes {
                            state.makeWorkout?.myRoutine.routines[index].workoutsType = type
                        }
                    }
                    return .send(.makeWorkout(.dismiss(myRoutine)))
                case .didUpdateText(let text):
                    state.makeWorkout?.myRoutine.name = text
                    return .none
                case .tappedAdd:
                    if let workoutCategory = state.makeWorkout?.addWorkoutCategory {
                        state.makeWorkout?.destination = .addWorkoutCategory(workoutCategory)
                    }
                    return .none
                case .destination(.presented(.addWorkoutCategory(let action))):
                    return .send(.makeWorkout(.addWorkoutCategory(action)))
                case .destination:
                    return .none
                    
                // MARK: - addmakeWorkout
                case .addWorkoutCategory(let action):
                    switch action {
                    case .getCategories:
                        return .run { send in
                            let categories = categoryRepository.loadCategories()
                            await send(.makeWorkout(.addWorkoutCategory(.updateCategories(categories))))
                        }
                    case .updateCategories(let categories):
                        state.makeWorkout?.addWorkoutCategory.categories = categories
                        return .none
                    case .dismissWorkoutCategory:
                        state.makeWorkout?.destination = .none
                        return .none
                        
                        // MARK: - addmakeWorkout workoutList
                    case .workoutList(let action):
                        switch action {
                        case let .getWorkouts(categoryName):
                            return .run { send in
                                let workouts = workoutRepository.loadWorkouts(categoryName)
                                await send(.makeWorkout(.addWorkoutCategory(.workoutList(.updateWorkouts(workouts)))))
                            }
                        case .updateWorkouts(let workouts):
                            if let myWorkout = state.makeWorkout?
                                .addWorkoutCategory
                                .workoutList
                                .myRoutine
                                .routines
                                .compactMap({ $0.workout }) {
                                let myWorkoutIDs = Set(myWorkout.map { $0.id }) // Set을 사용해 성능 최적화
                                state.makeWorkout?.addWorkoutCategory.workoutList.workouts = workouts.map { workout in
                                    let modifiedWorkout = workout
                                    modifiedWorkout.isSelected = myWorkoutIDs.contains(workout.id)
                                    return modifiedWorkout
                                }
                            }

                            return .none
                        case .makeWorkoutView(let routines):
                            state.makeWorkout?.destination = .none
                            state.makeWorkout?.workingOutSection = IdentifiedArrayOf(
                                uniqueElements: routines.map {
                                    WorkingOutSectionReducer.State(
                                        routine: $0,
                                        editMode: .active
                                    )
                                }
                            )
                            if let myRoutines = state.makeWorkout?.myRoutine.routines {
                                for routine in routines where !myRoutines.contains(routine) {
                                    state.makeWorkout?.myRoutine.routines.append(routine)
                                }
                            }
                            return .none
                        }
                    }
                case let .workingOutSection(action):
                    switch action {
                    case let .element(sectionId, action):
                        switch action {
                        case .tappedAddFooter:
                            if let sectionIndex = state.makeWorkout?
                                .workingOutSection
                                .index(id: sectionId) {
                                let workoutSet = WorkoutSet()
                                state.makeWorkout?
                                    .workingOutSection[sectionIndex]
                                    .workingOutRow
                                    .append(
                                        WorkingOutRowReducer.State(workoutSet: workoutSet,
                                                                   editMode: .active)
                                    )
                                state.makeWorkout?.myRoutine
                                    .routines[sectionIndex]
                                    .sets
                                    .append(workoutSet)
                            }
                            return .none
                        case let .workingOutRow(action):
                            switch action {
                            case let .element(rowId, action):
                                switch action {
                                case .toggleCheck:
                                    return .none
                                case let .typeLab(lab):
                                if let sectionIndex = state.makeWorkout?
                                        .workingOutSection
                                        .index(id: sectionId),
                                       let rowIndex = state.makeWorkout?
                                        .workingOutSection[sectionIndex]
                                        .workingOutRow
                                        .index(id: rowId),
                                       let labValue = Int(lab) {
                                        state.makeWorkout?.myRoutine
                                            .routines[sectionIndex]
                                            .sets[rowIndex]
                                            .lab = labValue
                                    }
                                    return .none
                                case let .typeWeight(weight):
                                    if let sectionIndex = state.makeWorkout?
                                        .workingOutSection
                                        .index(id: sectionId),
                                       let rowIndex = state.makeWorkout?
                                        .workingOutSection[sectionIndex]
                                        .workingOutRow
                                        .index(id: rowId),
                                       let weightValue = Double(weight) {
                                        state.makeWorkout?.myRoutine
                                            .routines[sectionIndex]
                                            .sets[rowIndex]
                                            .weight = weightValue
                                    }
                                    return .none
                                }
                            }
                        case let .workingOutHeader(action):
                            switch action {
                            case .deleteWorkout:
                                if let sectionIndex = state.makeWorkout?
                                    .workingOutSection
                                    .index(id: sectionId) {
                                    state.deletedSectionIndex = sectionIndex
                                    state.makeWorkout?
                                        .workingOutSection.remove(at: sectionIndex)
                                }
                                return .none
                            case let .tappedWorkoutsType(type):
                                if let sectionIndex = state.makeWorkout?
                                    .workingOutSection
                                    .index(id: sectionId) {
                                    state.changedTypes[sectionIndex] = type
                                }
                                return .none
                            }
                        case .setEditMode:
                            return .none
                        }
                    }
                }
                
            // MARK: - myRoutine
            case .myRoutineAction(let action):
                switch action {
                case .touchedMyRoutine(let selectedMyRoutine):
                    state.destination = .alert(.startMyRoutine(selectedMyRoutine))
                    return .none
                case .touchedEditMode(let myRoutine):
                    return .send(.createMakeWorkoutView(myRoutine: myRoutine, isEdit: true))
                }
            }
        }
    }
    
    private func saveMyRoutine() {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
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
        NavigationView {
            ScrollView {
                VStack {
                    if viewStore.myRoutineState.myRoutines.isEmpty == false {
                        MyRoutineView(
                            store: store.scope(state: \.myRoutineState,
                                               action: \.myRoutineAction)
                        )
                        .padding(.top, 10)
                    }
                    WorkoutCategoryView(
                        store: store.scope(state: \.workoutCategory,
                                           action: \.workoutCategory)
                    )
                    .padding(.top, 10)
                }
            }
            .background(Color(0xf4f4f4))
            .navigationBarTitle("workout", displayMode: .inline)
            .workoutViewToolbar(store: store, viewStore: viewStore)
            .onAppear {
                if !store.hasLoaded {
                    viewStore.send(.getMyRoutines)
                    viewStore.send(.hasLoaded)
                }
            }
        }
        .searchable(text: viewStore.binding(
            get: { $0.workoutCategory.keyword },
            send: { WorkoutReducer.Action.search(keyword: $0) }
        ))
        .fullScreenCover(
            item: $store.scope(state: \.destination?.makeWorkoutView,
                               action: \.destination.makeWorkoutView)
        ) { _ in
            if let store = store.scope(state: \.makeWorkout,
                                       action: \.makeWorkout) {
                MakeWorkoutView(store: store)
            }
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}

extension AlertState where Action == WorkoutReducer.Destination.Alert {
    static func startMyRoutine(_ myRoutine: MyRoutine) -> Self {
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
                if !viewStore.isEmptySelectedWorkouts {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            if !viewStore.isEmptySelectedWorkouts {
                                viewStore.send(.appearMakeWorkout)
                            } else {
                                store.myRoutine.routines += viewStore.workouts
                                    .filter({ $0.isSelected })
                                    .compactMap({ Routine(workouts: $0) })
                                
                            }
                        }) {
                            let selectedWorkout = viewStore.workouts.filter({ $0.isSelected })
                            Text("Done(\(selectedWorkout.count))")
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        viewStore.send(.dismiss)
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    })
                }
            })
    }
}
