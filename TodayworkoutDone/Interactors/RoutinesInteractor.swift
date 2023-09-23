//
//  RoutinesInteractor.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/08/04.
//

import Combine
import Foundation
import SwiftUI

protocol RoutinesInteractor {
    func load(myRoutines: LoadableSubject<LazyList<MyRoutine>>)
    func store(myRoutine: MyRoutine)
    
    func find(myRoutine: MyRoutine) -> Bool
    func load(workoutRoutines: LoadableSubject<LazyList<WorkoutRoutine>>)
    func store(workoutRoutine: WorkoutRoutine)
}

struct RealRoutinesInteractor: RoutinesInteractor {
    let dbRepository: RoutineDBRepository
    
    func load(myRoutines: LoadableSubject<LazyList<MyRoutine>>) {
        let cancelBag = CancelBag()
        
        myRoutines.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        dbRepository.routines()
            .sinkToLoadable {
                myRoutines.wrappedValue = $0
            }
            .store(in: cancelBag)
    }
    
    func store(myRoutine: MyRoutine) {
        let cancelBag = CancelBag()
        
        dbRepository.store(routine: myRoutine)
            .sink(receiveCompletion: { completion in
                if let error = completion.error {
                    print("\(error)")
                }
            }, receiveValue: {
                print("value: \($0)")
            })
            .store(in: cancelBag)
    }
    
    func find(myRoutine: MyRoutine) -> Bool {
        let cancelBag = CancelBag()
        
        var isFinded = false
        let semaphore = DispatchSemaphore(value: 0)
        dbRepository.find(routine: myRoutine)
            .sink(receiveCompletion: { _ in },
                  receiveValue: {
                defer { semaphore.signal() }
                isFinded = $0
            })
            .store(in: cancelBag)
        
        semaphore.wait()
        
        return isFinded
    }
    
    func load(workoutRoutines: LoadableSubject<LazyList<WorkoutRoutine>>) {
        
    }
    
    func store(workoutRoutine: WorkoutRoutine) {
        
    }
}

struct StubRoutineInteractor: RoutinesInteractor {
    func load(myRoutines: LoadableSubject<LazyList<MyRoutine>>) { }
    func store(myRoutine: MyRoutine) { }
    func find(myRoutine: MyRoutine) -> Bool {
        return false
    }
    func load(workoutRoutines: LoadableSubject<LazyList<WorkoutRoutine>>) { }
    func store(workoutRoutine: WorkoutRoutine) { }
}
