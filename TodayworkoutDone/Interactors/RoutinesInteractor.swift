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
    func update(myRoutine: MyRoutine, completion: @escaping () -> ())
    func find(myRoutine: MyRoutine) -> Bool
    func load(workoutRoutines: LoadableSubject<LazyList<WorkoutRoutine>>)
    func store(workoutRoutine: WorkoutRoutine)
}

struct RealRoutinesInteractor: RoutinesInteractor {
    let dbRepository: RoutineDBRepository
    let cancelBag = CancelBag()
    
    func load(myRoutines: LoadableSubject<LazyList<MyRoutine>>) {
        myRoutines.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        dbRepository.routines()
            .sinkToLoadable {
                myRoutines.wrappedValue = $0
            }
            .store(in: cancelBag)
    }
    
    func store(myRoutine: MyRoutine) {
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
    
    func update(myRoutine: MyRoutine, completion: @escaping () -> ()) {
        dbRepository.update(myRoutine: myRoutine)
            .sink(receiveCompletion: { receiveCompletion in
                if let error = receiveCompletion.error {
                    print("\(error)")
                }
            }, receiveValue: {
                print("value: \($0)")
                completion()
            })
            .store(in: cancelBag)
    }
    
    func find(myRoutine: MyRoutine) -> Bool {
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
        workoutRoutines.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        dbRepository.workoutRoutines()
            .sinkToLoadable {
                workoutRoutines.wrappedValue = $0
            }
            .store(in: cancelBag)
    }
    
    func store(workoutRoutine: WorkoutRoutine) {
        dbRepository.store(workoutRoutine: workoutRoutine)
            .sink(receiveCompletion: { completion in
                if let error = completion.error {
                    print("\(error)")
                }
            }, receiveValue: {
                print("value: \($0)")
            })
            .store(in: cancelBag)
    }
}

struct StubRoutineInteractor: RoutinesInteractor {
    func load(myRoutines: LoadableSubject<LazyList<MyRoutine>>) { }
    func store(myRoutine: MyRoutine) { }
    func update(myRoutine: MyRoutine, completion: @escaping () -> ()) {
        completion()
    }
    func find(myRoutine: MyRoutine) -> Bool {
        return false
    }
    func load(workoutRoutines: LoadableSubject<LazyList<WorkoutRoutine>>) { }
    func store(workoutRoutine: WorkoutRoutine) { }
}
