//
//  RoutineDBRepository.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/08/04.
//

import CoreData
import Combine

protocol RoutineDBRepository {
    func routines() -> AnyPublisher<LazyList<Routines>, Error>
    func store(routines: Routines) -> AnyPublisher<Void, Error>
}

struct RealRoutineDBRepository: RoutineDBRepository {
    let persistentStore: PersistentStore
    
    func routines() -> AnyPublisher<LazyList<Routines>, Error> {
        let fetchRequest = MyRoutineMO.routines()
        return persistentStore
            .fetch(fetchRequest) {
                MyRoutine(managedObject: $0)
            }
    }
    
    func store(routines: Routines) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update { context in
                routines.forEach {
                    $0.store(in: context)
                }
            }
    }
    
    
}

extension MyRoutineMO {
    static func routines() -> NSFetchRequest<MyRoutineMO> {
        let request = newFetchRequest()
        request.fetchBatchSize = 10
        return request
    }
}
