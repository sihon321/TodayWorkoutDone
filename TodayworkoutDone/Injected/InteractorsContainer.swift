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
        
        init(workoutInteractor: WorkoutInteractor,
             categoryInteractor: CategoryInteractor,
             routineInteractor: RoutinesInteractor) {
            self.workoutInteractor = workoutInteractor
            self.categoryInteractor = categoryInteractor
            self.routineInteractor = routineInteractor
        }
        
        static var stub: Self {
            .init(workoutInteractor: StubWorkoutInteractor(),
                  categoryInteractor: StubCategoryInteractor(),
                  routineInteractor: StubRoutineInteractor())
        }
    }
}
