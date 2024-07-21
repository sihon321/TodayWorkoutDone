//
//  WorkoutWebRepository.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/07/24.
//

import Combine
import Foundation

protocol WorkoutWebRepository {
    func loadWorkouts() -> AnyPublisher<[Workout], Error>
}

class RealWorkoutWebRepository: WorkoutWebRepository {
    func loadWorkouts() -> AnyPublisher<[Workout], Error> {
        let workouts: [Workout] = load("workouts.json")
        return Just<[Workout]>(workouts)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
