//
//  WorkouttDBRepository.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/07/17.
//

import CoreData
import Combine

protocol WorkoutDBRepository {
    func workouts(search: String) -> AnyPublisher<LazyList<Workouts>, Error>
}

struct RealWorkoutDBRepository: WorkoutDBRepository {
    let persistentStore: PersistentStore
    
    func workouts(search: String) -> AnyPublisher<LazyList<Workouts>, Error> {
        let fetchRequest = WorkoutsMO.workouts(search: search)
        return persistentStore
            .fetch(fetchRequest) {
                Workouts(managedObject: $0)
            }
    }
}

extension WorkoutsMO {
    static func workouts(search: String) -> NSFetchRequest<WorkoutsMO> {
        let request = newFetchRequest()
        if search.count == 0 {
            request.predicate = NSPredicate(value: true)
        }
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.fetchBatchSize = 10
        return request
    }
}
