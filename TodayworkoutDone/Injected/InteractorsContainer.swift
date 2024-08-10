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
        let routineInteractor: RoutinesInteractor
        let healthkitInteractor: HealthKitInteractor
        
        init(workoutInteractor: WorkoutInteractor,
             categoryInteractor: CategoryInteractor,
             routineInteractor: RoutinesInteractor,
             healthkitInteractor: HealthKitInteractor) {
            self.workoutInteractor = workoutInteractor
            self.categoryInteractor = categoryInteractor
            self.routineInteractor = routineInteractor
            self.healthkitInteractor = healthkitInteractor
        }
        
        static var stub: Self {
            .init(workoutInteractor: StubWorkoutInteractor(),
                  categoryInteractor: StubCategoryInteractor(),
                  routineInteractor: StubRoutineInteractor(),
                  healthkitInteractor: StubHealthKitInteractor())
        }
    }
}
