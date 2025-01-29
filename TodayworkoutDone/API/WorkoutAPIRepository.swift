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
    var loadWorkouts: (String) -> [Workout]
}

extension WorkoutAPIRepository: DependencyKey {
    public static let liveValue = Self(
        loadWorkouts: { name in
            let workouts: [Workout] = load("\(name).json")
            
            return workouts
        }
    )
}

extension WorkoutAPIRepository: TestDependencyKey {
    public static let testValue = Self(
        loadWorkouts: unimplemented("\(Self.self).loadWorkouts")
    )
}
