//
//  InteractorsContainer.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/30.
//

extension DIContainer {
    struct Interactors {
        let workoutInteractor: WorkoutInteractor
        
        init(workoutInteractor: WorkoutInteractor) {
            self.workoutInteractor = workoutInteractor
        }
        
        static var stub: Self {
            .init(workoutInteractor: StubWorkoutInteractor())
        }
    }
}
