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
        let interactors = configuredInteractors(appState: appState)
        let diContainer = DIContainer(appState: appState, interactors: interactors)
        let systemEventsHandler = RealSystemEventsHandler()
        
        return AppEnvironment(container: diContainer, systemEventsHandler: systemEventsHandler)
    }
    
    private static func configuredInteractors(appState: Store<AppState>) -> DIContainer.Interactors {
        let currentWorkoutInteractor = CurrentWorkoutInteractor(appState: appState)
        let workoutDataInteractor = WorkoutDataInteractor(appState: appState)
        return .init(workoutInteractor: currentWorkoutInteractor, workoutDataInteractor: workoutDataInteractor)
    }
}
