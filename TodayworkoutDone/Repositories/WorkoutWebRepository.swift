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
        let categories: [Workouts] = load("workouts.json")
        return Just<[Workouts]>(categories)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
