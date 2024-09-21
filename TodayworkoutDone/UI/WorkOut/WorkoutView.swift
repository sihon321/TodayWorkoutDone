//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import Dependencies
import ComposableArchitecture

@Reducer
struct WorkoutReducer {
    @ObservableState
    struct State: Equatable {
        var keyword: String = ""
        var workoutCategory = WorkoutCategoryReducer.State()
        var workouts: [Workout] = []
        var hasLoaded = false
    }
    
    enum Action {
        case search(keyword: String)
        case workoutCategory(WorkoutCategoryReducer.Action)
        case dismiss
        case hasLoaded
        
        var description: String {
            return "\(self)"
        }
    }
    
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
            case .workoutCategory(.setText(let keyword)):
                state.workoutCategory.keyword = keyword
                return .none
            case .dismiss:
                return .run { _ in
                  await dismiss(animation: .default)
                }
            case .hasLoaded:
                state.hasLoaded = true
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
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        viewStore.send(.dismiss)
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    })
                }
            })
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
    }
}
