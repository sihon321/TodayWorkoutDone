//
//  WorkoutAPIRepository.swift
//  TodayworkoutDone
//
//  Created by ocean on 9/16/24.
//

import Foundation
import Dependencies

extension DependencyValues {
    var workoutAPI: WorkoutAPIRepository {
        get { self[WorkoutAPIRepository.self] }
        set { self[WorkoutAPIRepository.self] = newValue }
    }
}

struct WorkoutAPIRepository {
    var loadWorkouts: () -> [Workout]
}

extension WorkoutAPIRepository: DependencyKey {
    public static let liveValue = Self(
        loadWorkouts: {
            let workouts: [Workout] = load("workouts.json")
            
            return workouts
        }
    )
}

extension WorkoutAPIRepository: TestDependencyKey {
    public static let testValue = Self(
        loadWorkouts: unimplemented("\(Self.self).loadWorkouts")
    )
}
