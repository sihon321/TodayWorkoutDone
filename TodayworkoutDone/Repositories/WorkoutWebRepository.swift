//
//  WorkoutWebRepository.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/07/24.
//

import Combine
import Foundation

protocol WorkoutWebRepository {
    func loadWorkouts() -> AnyPublisher<[Workouts], Error>
}

class RealWorkoutWebRepository: WorkoutWebRepository {
    func loadWorkouts() -> AnyPublisher<[Workouts], Error> {
        let workouts: [Workouts] = load("workouts.json")
        return Just<[Workouts]>(workouts)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
