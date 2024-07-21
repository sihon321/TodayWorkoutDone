//
//  AppState.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/05/29.
//

import Foundation

struct AppState: Equatable {
    var userData = UserData()
    var routing = ViewRouting()
    var system = System()
}

extension AppState {
    struct UserData: Equatable {
        var selectionWorkouts: [Workout] = []
        var myRoutine: MyRoutine = MyRoutine(name: "", routines: [])
        var workoutRoutines: [WorkoutRoutine] = []
    }
}

extension AppState {
    struct ViewRouting: Equatable {
        var homeView = HomeView.Routing()
//        var excerciseStartView = ExcerciseStartView.Routing()
        var workoutView = WorkoutView.Routing()
        var workoutCategoryView = WorkoutCategoryView.Routing()
        var workoutListView = WorkoutListView.Routing()
        var myWorkoutView = MyWorkoutView.Routing()
        var makeWorkoutView = MakeWorkoutView.Routing()
    }
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = false
    }
}

#if DEBUG
extension AppState {
    static var preview: AppState {
        let state = AppState()
        return state
    }
}
#endif
