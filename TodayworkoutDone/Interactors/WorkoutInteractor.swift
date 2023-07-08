//
//  WorkoutInteractor.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/30.
//

import Foundation

protocol WorkoutInteractor {
    func append(_ excercise: Excercise)
    func remove(_ excercise: Excercise)
    func contains(_ excercise: Excercise) -> Bool
}

struct CurrentWorkoutInteractor: WorkoutInteractor {
    let appState: Store<AppState>
    
    init(appState: Store<AppState>) {
        self.appState = appState
    }
    
    func append(_ excercise: Excercise) {
        appState[\.userData.selectionWorkouts].append(excercise)
    }
    
    func remove(_ excercise: Excercise) {
        appState[\.userData.selectionWorkouts].removeAll(where: {$0.id == excercise.id })
    }
    
    func contains(_ excercise: Excercise) -> Bool {
        return appState[\.userData.selectionWorkouts].contains(excercise)
    }
}

struct StubWorkoutInteractor: WorkoutInteractor {
    func append(_ excercise: Excercise) { }
    func remove(_ excercise: Excercise) { }
    func contains(_ excercise: Excercise) -> Bool { return true }
}
