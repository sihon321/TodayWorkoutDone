//
//  WorkoutDBRepository.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/07/17.
//

import CoreData
import Combine

protocol WorkoutDBRepository {
    func hasLoadedWorkouts() -> AnyPublisher<Bool, Error>
    func workouts() -> AnyPublisher<LazyList<Workouts>, Error>
    func store(workouts: [Workouts]) -> AnyPublisher<Void, Error>
}

struct RealWorkoutDBRepository: WorkoutDBRepository {
    let persistentStore: PersistentStore
    
    func hasLoadedWorkouts() -> AnyPublisher<Bool, Error> {
        let fetchRequest = WorkoutsMO.workouts()
        return persistentStore
            .count(fetchRequest)
            .map { $0 > 0 }
            .eraseToAnyPublisher()
    }
    
    func workouts() -> AnyPublisher<LazyList<Workouts>, Error> {
        let fetchRequest = WorkoutsMO.workouts()
        return persistentStore
            .fetch(fetchRequest) {
                Workouts(managedObject: $0)
            }
    }
    
    func store(workouts: [Workouts]) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update { context in
                workouts.forEach {
                    $0.store(in: context)
                }
            }
    }
}

extension WorkoutsMO {
    static func workouts(name: [String] = []) -> NSFetchRequest<WorkoutsMO> {
        let request = newFetchRequest()
        if !name.isEmpty {
            request.predicate = NSPredicate(format: "name in %@", name)
        }
        request.fetchBatchSize = 10
        return request
    }
}
