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
}

struct StubRoutineInteractor: RoutinesInteractor {
    func load(myRoutines: LoadableSubject<LazyList<MyRoutine>>) { }
    func store(myRoutine: MyRoutine) { }
}
