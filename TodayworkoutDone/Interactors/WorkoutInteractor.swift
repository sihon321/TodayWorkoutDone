//
//  WorkoutInteractor.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/30.
//

import Combine
import Foundation
import SwiftUI

protocol WorkoutInteractor {
    func append(_ excercise: Workouts)
    func remove(_ excercise: Workouts)
    func contains(_ excercise: Workouts) -> Bool
    
    func load(workouts: LoadableSubject<LazyList<Workouts>>)
}

struct CurrentWorkoutInteractor: WorkoutInteractor {
    let webRepository: WorkoutWebRepository
    let dbRepository: WorkoutDBRepository
    let appState: Store<AppState>
    
    init(webRepository: WorkoutWebRepository,
         dbRepository: WorkoutDBRepository,
         appState: Store<AppState>) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
    }
    
    func append(_ excercise: Workouts) {
        appState[\.userData.selectionWorkouts].append(excercise)
    }
    
    func remove(_ excercise: Workouts) {
        appState[\.userData.selectionWorkouts].removeAll(where: {$0.id == excercise.id })
    }
    
    func contains(_ excercise: Workouts) -> Bool {
        return appState[\.userData.selectionWorkouts].contains(excercise)
    }
    
    func load(workouts: LoadableSubject<LazyList<Workouts>>) {
        let cancelBag = CancelBag()
        
        Just<Void>
            .withErrorType(Error.self)
            .flatMap { [dbRepository] _ -> AnyPublisher<Bool, Error> in
                dbRepository.hasLoadedWorkouts()
            }
            .flatMap { hasLoaded -> AnyPublisher<Void, Error> in
                if hasLoaded {
                    return Just<Void>.withErrorType(Error.self)
                } else {
                    return self.refreshWorkoutsList()
                }
            }
            .flatMap { [dbRepository] in
                dbRepository.workouts()
            }
            .sinkToLoadable { workouts.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    func refreshWorkoutsList() -> AnyPublisher<Void, Error> {
        return webRepository
            .loadWorkouts()
            .flatMap { [dbRepository] in
                dbRepository.store(workouts: $0)
            }
            .eraseToAnyPublisher()
    }
}

struct StubWorkoutInteractor: WorkoutInteractor {
    func append(_ excercise: Workouts) { }
    func remove(_ excercise: Workouts) { }
    func contains(_ excercise: Workouts) -> Bool { return true }
    func load(workouts: LoadableSubject<LazyList<Workouts>>) { }
}
