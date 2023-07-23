//
//  InteractorsContainer.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/30.
//

extension DIContainer {
    struct Interactors {
        let workoutInteractor: WorkoutInteractor
        let categoryInteractor: CategoryInteractor
        
        init(workoutInteractor: WorkoutInteractor, categoryInteractor: CategoryInteractor) {
            self.workoutInteractor = workoutInteractor
            self.categoryInteractor = categoryInteractor
        }
        
        static var stub: Self {
            .init(workoutInteractor: StubWorkoutInteractor(),
                  categoryInteractor: StubCategoryInteractor())
        }
    }
}
