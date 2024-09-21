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
    struct State: Equatable {
        var workoutsList: [Workout] = []
        var selectWorkouts: [Workout] = []
        var myRoutine: MyRoutine = MyRoutine(id: UUID(), name: "", routines: [])
        var isMyWorkoutView: Bool = false
        var category: Category = Category(name: "")
    }
    
    enum Action {
        
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            }
        }
    }
}

struct WorkoutListView: View {
    @Bindable var store: StoreOf<WorkoutListReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkoutListReducer>
    
    init(store: StoreOf<WorkoutListReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        List(viewStore.workoutsList.filter({ viewStore.category.name == $0.category })) { workouts in
            WorkoutListSubview(workouts: workouts,
                               selectWorkouts: .constant(viewStore.selectWorkouts))
        }
        .listStyle(.plain)
        .toolbar {
            if !viewStore.selectWorkouts.isEmpty {
                Button(action: {
                    if !viewStore.isMyWorkoutView {
//                        injected.appState[\.routing.workoutListView.makeWorkoutView] = true
                    } else {
                        viewStore.myRoutine.routines += viewStore.selectWorkouts.compactMap({ Routine(workouts: $0) })
//                        injected.appState[\.userData.selectionWorkouts].removeAll()
//                        injected.appState[\.routing.makeWorkoutView.workoutCategoryView] = false
                    }
                }) {
                    Text("Done(\(viewStore.selectWorkouts.count))")
                }
                .fullScreenCover(isPresented: .constant(false),
                                 content: {
                    if !viewStore.isMyWorkoutView {
                        MakeWorkoutView(
                            store: Store(initialState: MakeWorkoutReducer.State()) {
                                MakeWorkoutReducer()
                            }
                        )
                    }
                })
            }
        }
        .navigationTitle(viewStore.category.name)
    }
}

// MARK: - Side Effects

private extension WorkoutListView {
    func reloadWorkouts() {
//        injected.interactors.workoutInteractor
//            .load(workouts: $workoutsList)
    }
}
