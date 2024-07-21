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
    func append(_ excercise: Workout)
    func remove(_ excercise: Workout)
    func contains(_ excercise: Workout) -> Bool
    
    func load(workouts: LoadableSubject<LazyList<Workout>>)
    func load(workouts: Binding<LazyList<Workout>>)
}

struct RealWorkoutInteractor: WorkoutInteractor {
    let webRepository: WorkoutWebRepository
    let dbRepository: WorkoutDBRepository
    let appState: LegacyStore<AppState>
    
    init(webRepository: WorkoutWebRepository,
         dbRepository: WorkoutDBRepository,
         appState: LegacyStore<AppState>) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
    }
    
    func append(_ excercise: Workout) {
        appState[\.userData.selectionWorkouts].append(excercise)
    }
    
    func remove(_ excercise: Workout) {
        appState[\.userData.selectionWorkouts].removeAll(where: {$0.id == excercise.id })
    }
    
    func contains(_ excercise: Workout) -> Bool {
        return appState[\.userData.selectionWorkouts].contains(excercise)
    }
    
    func load(workouts: LoadableSubject<LazyList<Workout>>) {
        let cancelBag = CancelBag()
        
        workouts.wrappedValue.setIsLoading(cancelBag: cancelBag)
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
    
    func load(workouts: Binding<LazyList<Workout>>) {
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
            .sinkToLoadable { workouts.wrappedValue = $0.value ?? .empty }
            .store(in: cancelBag)
    }
    
    private func refreshWorkoutsList() -> AnyPublisher<Void, Error> {
        return webRepository
            .loadWorkouts()
            .flatMap { [dbRepository] in
                dbRepository.store(workouts: $0)
            }
            .eraseToAnyPublisher()
    }
}

struct StubWorkoutInteractor: WorkoutInteractor {
    func append(_ excercise: Workout) { }
    func remove(_ excercise: Workout) { }
    func contains(_ excercise: Workout) -> Bool { return true }
    func load(workouts: LoadableSubject<LazyList<Workout>>) { }
    func load(workouts: Binding<LazyList<Workout>>) { }
}
