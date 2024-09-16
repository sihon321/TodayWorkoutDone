//
//  WorkoutListView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI
import ComposableArchitecture
import Combine

struct WorkoutListView: View {
    @State private var workoutsList: [Workout]
    @State private var selectWorkouts: [Workout]
    @Binding var myRoutine: MyRoutine
    private var isMyWorkoutView: Bool
    
    var category: Category
    
    init(workoutsList: [Workout],
         selectWorkouts: [Workout],
         category: Category,
         isMyWorkoutView: Bool = false,
         myRoutine: Binding<MyRoutine> = .init(projectedValue: .constant(MyRoutine(name: "", routines: [])))) {
        self._workoutsList = .init(initialValue: workoutsList)
        self._selectWorkouts = .init(initialValue: selectWorkouts)
        self.category = category
        self.isMyWorkoutView = isMyWorkoutView
        self._myRoutine = myRoutine
    }
    
    var body: some View {
        List(workoutsList.filter({ category.name == $0.category })) { workouts in
            WorkoutListSubview(workouts: workouts,
                               selectWorkouts: $selectWorkouts)
        }
        .listStyle(.plain)
        .toolbar {
            if !selectWorkouts.isEmpty {
                Button(action: {
                    if !isMyWorkoutView {
//                        injected.appState[\.routing.workoutListView.makeWorkoutView] = true
                    } else {
                        myRoutine.routines += selectWorkouts.compactMap({ Routine(workouts: $0) })
//                        injected.appState[\.userData.selectionWorkouts].removeAll()
//                        injected.appState[\.routing.makeWorkoutView.workoutCategoryView] = false
                    }
                }) {
                    Text("Done(\(selectWorkouts.count))")
                }
                .fullScreenCover(isPresented: .constant(false),
                                 content: {
                    if !isMyWorkoutView {
                        MakeWorkoutView(
                            myRoutine: .constant(MyRoutine(
                                name: "",
                                routines: selectWorkouts.compactMap({ Routine(workouts: $0) }))
                            )
                        )
                    }
                })
            }
        }
            .navigationTitle(category.name)
    }
}

// MARK: - Side Effects

private extension WorkoutListView {
    func reloadWorkouts() {
//        injected.interactors.workoutInteractor
//            .load(workouts: $workoutsList)
    }
}
