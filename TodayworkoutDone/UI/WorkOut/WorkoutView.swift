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
        
        var keyword: String = ""
        var workoutCategory = WorkoutCategoryReducer.State()
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
        mutating func refetch(_ myRoutine: MyRoutine?) {
            @Dependency(\.myRoutineData) var context
            do {
                self.myRoutine = try context.fetch(self.fetchDescriptor).first
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        
        case search(keyword: String)
        case workoutCategory(WorkoutCategoryReducer.Action)
        case dismiss
        case hasLoaded
        
        case addMyRoutine
        case appearMakeWorkoutView(MyRoutine?)
        
        var description: String {
            return "\(self)"
        }
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case makeWorkoutView(MakeWorkoutReducer)
    }
    
    @Dependency(\.myRoutineData) var context
    @Dependency(\.categoryAPI) var categoryRepository
    @Dependency(\.workoutAPI) var workoutRepository
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in			
            print(action.description)
            switch action {
            case .search(let keyword):
                state.keyword = keyword
                return .none
            case .destination:
                return .none
            case .dismiss:
                return .run { _ in
                  await dismiss(animation: .default)
                }
            case .hasLoaded:
                state.hasLoaded = true
                return .none
            case .addMyRoutine:
                do {
                    let routines = state.workouts
                        .filter({ $0.isSelected })
                        .compactMap({
                            return Routine(workouts: $0)
                        })
                    let myRoutine = MyRoutine(
                        name: "",
                        routines: routines
                    )
                    try context.add(myRoutine)
                    return .run { @MainActor send in
                        send(.appearMakeWorkoutView(myRoutine))
                    }
                } catch {
                    print(error.localizedDescription)
                    return .none
                }
            case .appearMakeWorkoutView(let myRoutine):
                state.refetch(myRoutine)
                if let myRoutine = myRoutine {
                    state.destination = .makeWorkoutView(
                        MakeWorkoutReducer.State(myRoutine: myRoutine)
                    )
                }
                return .none
            case .workoutCategory(.setText(let keyword)):
                state.workoutCategory.keyword = keyword
                return .none
            case .workoutCategory(.getCategories):
                return .run { send in
                    let categories = categoryRepository.loadCategories()
                    await send(.workoutCategory(.updateCategories(categories)))
                }
            case .workoutCategory(.updateCategories(let categories)):
                state.workoutCategory.categories = categories
                return .none
                
            case .workoutCategory(.workoutList(.getWorkouts)):
                return .run { send in
                    let workouts = workoutRepository.loadWorkouts()
                    await send(.workoutCategory(.workoutList(.updateWorkouts(workouts))))
                }
            case .workoutCategory(.workoutList(.updateWorkouts(let workouts))):
                state.workouts = workouts
                state.workoutCategory.workoutList.workouts = workouts
                return .none
            case .workoutCategory(.workoutList(.makeWorkoutView)):
                return .send(.addMyRoutine)
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
                    MyWorkoutView(
                        myRoutines: [],
                        workoutsList: .constant([])
                    )
                    .padding(.top, 10)
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
