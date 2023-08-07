//
//  AppEnvironment.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/30.
//

import Foundation
import Combine

struct AppEnvironment {
    let container: DIContainer
    let systemEventsHandler: SystemEventHandler
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        
        let webRepositories = configuredWebRepositories()
        let dbRepositories = configuredDBRepositories()
        
        let interactors = configuredInteractors(appState: appState,
                                                dbRepositories: dbRepositories,
                                                webRepositories: webRepositories)
        let diContainer = DIContainer(appState: appState, interactors: interactors)
        let systemEventsHandler = RealSystemEventsHandler()
        
        return AppEnvironment(container: diContainer, systemEventsHandler: systemEventsHandler)
    }
    
    private static func configuredWebRepositories() -> DIContainer.WebRepositories {
        let categoryRepository = RealCategoryWebRepository()
        let workgoutsRepository = RealWorkoutWebRepository()
        
        return .init(workoutsRepository: workgoutsRepository, categoryRepository: categoryRepository)
    }
    
    private static func configuredDBRepositories() -> DIContainer.DBRepositories {
        let persistentStore = CoreDataStack(version: CoreDataStack.Version.actual)
        let categoryRepository = RealCategoryDBRepository(persistentStore: persistentStore)
        let workgoutsRepository = RealWorkoutDBRepository(persistentStore: persistentStore)
        let routineRepository = RealRoutineDBRepository(persistentStore: persistentStore)
        
        return .init(workoutsRepository: workgoutsRepository,
                     categoryRepository: categoryRepository,
                     routineRepository: routineRepository)
    }
    
    private static func configuredInteractors(appState: Store<AppState>,
                                              dbRepositories: DIContainer.DBRepositories,
                                              webRepositories: DIContainer.WebRepositories
    ) -> DIContainer.Interactors {
        let workoutInteractor = RealWorkoutInteractor(
            webRepository: webRepositories.workoutsRepository,
            dbRepository: dbRepositories.workoutsRepository,
            appState: appState
        )
        let categoryInteractor = RealCategoryInteractor(
            webRepository: webRepositories.categoryRepository,
            dbRepository: dbRepositories.categoryRepository,
            appState: appState)
        let routineInteractor = RealRoutinesInteractor(dbRepository: dbRepositories.routineRepository)
        
        return .init(workoutInteractor: workoutInteractor,
                     categoryInteractor: categoryInteractor,
                     routineInteractor: routineInteractor)
    }
}

extension DIContainer {
    struct WebRepositories {
        let workoutsRepository: WorkoutWebRepository
        let categoryRepository: CategoryWebRepository
    }
    
    struct DBRepositories {
        let workoutsRepository: WorkoutDBRepository
        let categoryRepository: CategoryDBRepository
        let routineRepository: RoutineDBRepository
    }
}
