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
        var myRoutine: MyRoutine = MyRoutine(id: UUID(), name: "", routines: [])
        var isMyWorkoutView: Bool = false
        var category: Category = .init(name: "")
    }
    
    enum Action {
        case getWorkouts
        case updateWorkouts([Workout])
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
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
    private var category: Category
    
    init(store: StoreOf<WorkoutListReducer>, category: Category) {
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
            if !viewStore.workouts.compactMap({ $0.isSelected }).isEmpty {
                Button(action: {
                    if !viewStore.isMyWorkoutView {

                    } else {
                        viewStore.myRoutine.routines += viewStore.workouts
                            .filter({ $0.isSelected })
                            .compactMap({ Routine(workouts: $0) })
                    }
                }) {
                    let selectedWorkout = viewStore.workouts.filter({ $0.isSelected })
                    Text("Done(\(selectedWorkout.count))")
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
