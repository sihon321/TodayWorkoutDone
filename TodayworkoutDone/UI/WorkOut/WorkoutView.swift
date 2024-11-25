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
        
        var workoutCategory: WorkoutCategoryReducer.State
        var myRoutineState = MyRoutineReducer.State()
        var makeWorkout: MakeWorkoutReducer.State?
        var workouts: [Workout] = []
        var hasLoaded = false
        
        var myRoutine: MyRoutine? = nil
        
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
            guard let myRoutine = myRoutine else {
                return #Predicate { _ in
                    false
                }
            }
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
        mutating func refetch(_ myRoutine: MyRoutine?) -> MyRoutine? {
            @Dependency(\.myRoutineData) var context
            self.myRoutine = myRoutine
            do {
                self.myRoutine = try context.fetch(self.fetchDescriptor).first
                return self.myRoutine
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        
        init(_ myRoutine: MyRoutine?) {
            self.myRoutine = myRoutine
            self.workoutCategory = WorkoutCategoryReducer.State(myRoutine)
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
        case filterWorkout
        case appearMakeWorkoutView(MyRoutine?)
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
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
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
                    if store.myRoutineState.myRoutines.isEmpty == false {
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
                    viewStore.send(.workoutCategory(.workoutList(.getWorkouts)))
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
                                viewStore.send(.filterWorkout)
                            } else {
                                store.myRoutine?.routines += viewStore.workouts
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
