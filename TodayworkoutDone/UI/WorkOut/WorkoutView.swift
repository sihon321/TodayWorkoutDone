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
        var myRoutine: MyRoutine
        var keyword: String = ""
        var myRoutineState: MyRoutineReducer.State
        
        var categories: Categories = []
        var hasLoaded = false
        
        init(myRoutine: MyRoutine,
             myRoutineState: MyRoutineReducer.State) {
            self.myRoutine = myRoutine
            self.myRoutineState = myRoutineState
        }
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        
        case myRoutineAction(MyRoutineReducer.Action)
        
        case search(keyword: String)
        case dismiss
        case hasLoaded
        case getCategories
        case updateCategories(Categories)
        case getMyRoutines
        case fetchMyRoutines([MyRoutine])
        
        case appearMakeWorkout
        case createMakeWorkoutView(myRoutine: MyRoutine?, isEdit: Bool)
        
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
                state.keyword = keyword
                return .none
            case .dismiss:
                state.destination = .none
                return .run { _ in
                    await self.dismiss()
                }
            case .hasLoaded:
                state.hasLoaded = true
                return .none
            case .getCategories:
                return .run { send in
                    let categories = categoryRepository.loadCategories()
                    await send(.updateCategories(categories))
                }
            case .updateCategories(let categories):
                state.categories = categories
                return .none
            case .getMyRoutines:
                return .run { send in
                    let myRoutines = try context.fetchAll()
                    await send(.fetchMyRoutines(myRoutines))
                }
                
            case .fetchMyRoutines(let myRoutines):
                state.myRoutineState.myRoutines = myRoutines
                return .none
                
            case .appearMakeWorkout:
                return .send(.createMakeWorkoutView(myRoutine: state.myRoutine,
                                                    isEdit: false))
            case let .createMakeWorkoutView(myRoutine, isEdit):
                state.destination = .makeWorkoutView(MakeWorkoutReducer.State(
                    myRoutine: myRoutine ?? state.myRoutine,
                    categories: state.categories,
                    isEdit: isEdit,
                ))
                
                return .none
                
            case .destination(.presented(.alert(.tappedMyRoutineStart(let myRoutine)))):
//                return .send(.makeWorkout(.tappedDone(myRoutine)))
                return .none
            case .destination:
                return .none
                
            // MARK: - myRoutine
            case let .myRoutineAction(action):
                switch action {
                case let .touchedMyRoutine(selectedMyRoutine):
                    state.destination = .alert(.startMyRoutine(selectedMyRoutine))
                    return .none
                case let .touchedEditMode(myRoutine):
                    return .send(.createMakeWorkoutView(myRoutine: myRoutine, isEdit: true))
                case let .touchedDelete(myRoutine):
                    let id = myRoutine.persistentModelID
                    return .run { send in
                        let descriptor = FetchDescriptor<MyRoutine>(
                            predicate: #Predicate { $0.persistentModelID == id }
                        )
                        if let routineToDelete = try context.fetch(descriptor).first {
                            try context.delete(routineToDelete)
                            try context.save()
                        }

                        await send(.getMyRoutines)
                    }
                }
            case .destination(.presented(.makeWorkoutView(.tappedDone(let myRoutine)))):
                state.myRoutine = myRoutine
                state.myRoutine.isRunning = true
//                if let runningRoutine = state.myRoutine {
//                    state.workingOut = WorkingOutReducer.State(
//                        myRoutine: runningRoutine,
//                        workingOutSection: IdentifiedArrayOf(
//                            uniqueElements: runningRoutine.routines.map {
//                                WorkingOutSectionReducer.State(
//                                    routine: $0,
//                                    editMode: .inactive
//                                )
//                            }
//                        )
//                    )
//                    if let myRoutine = state.workingOut?.myRoutine  {
//                        state.workoutRoutine = WorkoutRoutine(
//                            name: myRoutine.name,
//                            startDate: Date(),
//                            myRoutine: myRoutine
//                        )
//                    }
//                }

                return .none
                
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
                        store: Store(
                            initialState: WorkoutCategoryReducer.State(
                                myRoutine: store.myRoutine,
                                workoutList: IdentifiedArrayOf(
                                    uniqueElements: store.categories.compactMap {
                                        WorkoutListReducer.State(id: UUID(),
                                                                 isAddWorkoutPresented: false,
                                                                 myRoutine: store.myRoutine,
                                                                 categoryName: $0.name,
                                                                 categories: store.categories)
                                    }
                                )
                            )
                        ) {
                            WorkoutCategoryReducer()
                        }
                    )
                    .padding(.top, 10)
                }
            }
            .background(Color(0xf4f4f4))
            .navigationBarTitle("workout", displayMode: .inline)
            .workoutViewToolbar(store: store, viewStore: viewStore)
            .onAppear {
                if !store.hasLoaded {
                    viewStore.send(.hasLoaded)
                }
            }
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
                if !viewStore.myRoutine.routines.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewStore.send(.appearMakeWorkout)
                        }) {
                            let selectedWorkoutCount = viewStore.myRoutine.routines.count
                            Text("Done(\(selectedWorkoutCount))")
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
