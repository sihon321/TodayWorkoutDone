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
        case makeWorkoutView
        case getWorkouts
        case updateWorkouts([Workout])
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .makeWorkoutView:
                return .none
            case .getWorkouts:
                return .none
            case .updateWorkouts:
                return .none
            }
        }
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
        List(viewStore.workouts.filter({ category.name == $0.category })) { workouts in
            WorkoutListSubview(workouts: workouts)
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !viewStore.isEmptySelectedWorkouts {
                    Button(action: {
                        if !viewStore.isEmptySelectedWorkouts {
                            viewStore.send(.makeWorkoutView)
                        } else {
                            viewStore.myRoutine?.routines += viewStore.workouts
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
