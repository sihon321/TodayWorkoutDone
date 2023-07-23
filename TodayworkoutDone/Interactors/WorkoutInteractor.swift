//
//  WorkoutInteractor.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/30.
//

import Foundation

protocol WorkoutInteractor {
    func append(_ excercise: Workouts)
    func remove(_ excercise: Workouts)
    func contains(_ excercise: Workouts) -> Bool
}

struct CurrentWorkoutInteractor: WorkoutInteractor {
    let appState: Store<AppState>
    
    init(appState: Store<AppState>) {
        self.appState = appState
    }
    
    func append(_ excercise: Workouts) {
        appState[\.userData.selectionWorkouts].append(excercise)
    }
    
    func remove(_ excercise: Workouts) {
        appState[\.userData.selectionWorkouts].removeAll(where: {$0.id == excercise.id })
    }
    
    func contains(_ excercise: Workouts) -> Bool {
        return appState[\.userData.selectionWorkouts].contains(excercise)
    }
}

struct StubWorkoutInteractor: WorkoutInteractor {
    func append(_ excercise: Workouts) { }
    func remove(_ excercise: Workouts) { }
    func contains(_ excercise: Workouts) -> Bool { return true }
}
