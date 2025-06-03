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
                WorkoutSet(prevWeight: 30, weight: 40, prevReps: 12, reps: 12),
                WorkoutSet(prevWeight: 40, weight: 50, prevReps: 12, reps: 12),
                WorkoutSet(prevWeight: 50, weight: 60, prevReps: 12, reps: 10),
                WorkoutSet(prevWeight: 60, weight: 80, prevReps: 10, reps: 5)
            ],
            averageEndDate: 43
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
