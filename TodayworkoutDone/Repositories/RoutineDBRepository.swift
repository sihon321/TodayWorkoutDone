//
//  RoutineDBRepository.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/08/04.
//

import CoreData
import Combine

protocol RoutineDBRepository {
    func hasLoadedRoutines() -> AnyPublisher<Bool, Error>
    func routines() -> AnyPublisher<LazyList<MyRoutine>, Error>
    func store(routine: MyRoutine) -> AnyPublisher<Void, Error>
}

struct RealRoutineDBRepository: RoutineDBRepository {
    let persistentStore: PersistentStore
    
    func hasLoadedRoutines() -> AnyPublisher<Bool, Error> {
        let fetchRequest = MyRoutineMO.routines()
        return persistentStore
            .count(fetchRequest)
            .map { $0 > 0 }
            .eraseToAnyPublisher()
    }
    
    func routines() -> AnyPublisher<LazyList<MyRoutine>, Error> {
        let fetchRequest = MyRoutineMO.routines()
        return persistentStore
            .fetch(fetchRequest) {
                MyRoutine(managedObject: $0)
            }
    }
    
    func store(routine: MyRoutine) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update { context in
                let workoutName = routine.routines.compactMap { $0.workouts.name }
                let workoutFetchRequest = WorkoutsMO.workouts(name: workoutName)
                guard let workouts = try? context.fetch(workoutFetchRequest) else {
                    return
                }
                let setsMO = routine.routines.compactMap {
                    $0.sets.compactMap {
                        $0.store(in: context)
                    }
                }

                routine.store(in: context, name: routine.name, workouts: workouts, sets: setsMO)
            }
    }
}

extension SetsMO {
    static func sets(id: [UUID] = []) -> NSFetchRequest<SetsMO> {
        let request = newFetchRequest()
        if !id.isEmpty {
            request.predicate = NSPredicate(format: "id in %@", id)
        }
        request.fetchBatchSize = 10
        return request
    }
}

extension MyRoutineMO {
    static func routines() -> NSFetchRequest<MyRoutineMO> {
        let request = newFetchRequest()
        request.fetchBatchSize = 10
        return request
    }
}
