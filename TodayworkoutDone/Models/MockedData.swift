//
//  MockedData.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/07/23.
//

import Foundation

extension WorkoutCategory {
    static let mockedData: [WorkoutCategory] = [
        WorkoutCategory(name: "헬스"),
        WorkoutCategory(name: "요가"),
        WorkoutCategory(name: "필라테스")
    ]
}

extension Workout {
    static let mockedData: [Workout] = [
        Workout(name: "벤치프레스", category: WorkoutCategoryState(name: "gym"), target: "하체", isSelected: false),
        Workout(name: "데드리프트", category: WorkoutCategoryState(name: "gym"), target: "하체", isSelected: false),
        Workout(name: "스쿼트", category: WorkoutCategoryState(name: "gym"), target: "하체", isSelected: false)
    ]
}

extension Routine {
    static let mockedData: [Routine] = Workout.mockedData.compactMap {
        Routine(
            index: 0,
            workout: $0,
            sets: [
                WorkoutSet(prevWeight: 4000, weight: 5000, prevReps: 1200, reps: 1200),
                WorkoutSet(prevWeight: 5000, weight: 6000, prevReps: 1200, reps: 1200),
                WorkoutSet(prevWeight: 6000, weight: 7000, prevReps: 1200, reps: 1200)
            ]
        )
    }
}

extension MyRoutine {
    static let mockedData: MyRoutine = MyRoutine(name: "test", routines: Routine.mockedData)
}

extension WorkoutRoutine {
    static let mockedData: WorkoutRoutine = WorkoutRoutine(name: "Test",
                                                           startDate: Date(),
                                                           endDate: Date(),
                                                           routines: Routine.mockedData)
}

extension WorkoutSet {
    static let mockedData: [WorkoutSet] = [
        WorkoutSet(), WorkoutSet(), WorkoutSet()
    ]
}
