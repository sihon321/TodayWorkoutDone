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
        var workouts: [Workout] = []
        var myRoutine: MyRoutine?
        
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
        var category: WorkoutCategory = .init(name: "")
    }
    
    enum Action {
        case makeWorkoutView([Routine])
        case getWorkouts
        case updateWorkouts([Workout])
    }
}

struct WorkoutListView: View {
    @Bindable var store: StoreOf<WorkoutListReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkoutListReducer>
    private var category: WorkoutCategory
    
    init(store: StoreOf<WorkoutListReducer>, category: WorkoutCategory) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        self.category = category
    }
    
    var body: some View {
        List(store.workouts.filter({ category.name == $0.category })) { workouts in
            WorkoutListSubview(store: store, workouts: workouts)
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !viewStore.isEmptySelectedWorkouts {
                    Button(action: {
                        if !viewStore.isEmptySelectedWorkouts {
                            let routines = viewStore.workouts
                                .filter({ $0.isSelected })
                                .compactMap({ Routine(workouts: $0) })
                            store.send(.makeWorkoutView(routines))
                        } else {
                            viewStore.myRoutine?.routines += store.workouts
                                .filter({ $0.isSelected })
                                .compactMap({ Routine(workouts: $0) })
                        }
                    }) {
                        let selectedWorkout = viewStore.workouts.filter({ $0.isSelected })
                        Text("Done(\(selectedWorkout.count))")
                    }
                }
            }
        }
        .navigationTitle(viewStore.category.name)
    }
}
