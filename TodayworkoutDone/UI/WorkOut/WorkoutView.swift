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
        
        init(myRoutine: MyRoutineState) {
            self.myRoutine = myRoutine
        }
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        
        case search(keyword: String)
        case dismiss

        case getCategories
        case updateCategories([WorkoutCategoryState])
        case getMyRoutines
        case fetchMyRoutines([MyRoutineState])
        
        case createMakeWorkoutView(myRoutine: MyRoutineState?, isEdit: Bool)
        
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
    
    @Dependency(\.myRoutineData) var context
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
                return .none
            case .dismiss:
                state.destination = .none
                return .run { _ in
                    await self.dismiss()
                }

            case .getCategories:
                return .run { send in
                    let categories = categoryRepository.loadCategories()
                    await send(.updateCategories(categories))
                }
            case .updateCategories(let categories):
                state.categories = categories
                state.workoutCategory.workoutList = IdentifiedArrayOf(
                    uniqueElements: categories.compactMap {
                        WorkoutListReducer.State(id: UUID(),
                                                 isAddWorkoutPresented: false,
                                                 myRoutine: state.myRoutine,
                                                 categoryName: $0.name,
                                                 categories: categories)
                    }
                )
                return .none
            case .getMyRoutines:
                return .run { send in
                    let myRoutines = try context.fetchAll()
                        .compactMap { MyRoutineState(model: $0) }
                    await send(.fetchMyRoutines(myRoutines))
                }
                
            case .fetchMyRoutines(let myRoutines):
                state.myRoutineReducer.myRoutines = myRoutines
                return .none
                

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
            case .workoutCategory(let action):
                return .none
            // MARK: - myRoutine
            case let .myRoutineReducer(action):
                switch action {
                case let .touchedMyRoutine(selectedMyRoutine):
                    state.destination = .alert(.startMyRoutine(selectedMyRoutine))
                    return .none
                case let .touchedEditMode(myRoutine):
                    return .send(.createMakeWorkoutView(myRoutine: myRoutine, isEdit: true))
                case let .touchedDelete(myRoutine):
                    if let id = myRoutine.persistentModelID {
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
                    } else {
                        return .none
                    }
                }
            // MARK: - workoutCategory
                
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
                    if viewStore.myRoutineReducer.myRoutines.isEmpty == false {
                        MyRoutineView(
                            store: store.scope(state: \.myRoutineReducer,
                                               action: \.myRoutineReducer)
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
                            viewStore.send(.createMakeWorkoutView(myRoutine: store.myRoutine,
                                                                  isEdit: false))
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
