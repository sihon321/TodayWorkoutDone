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
        Workout(name: "스쿼시", category: "gym", target: "하체", isSelected: false),
        Workout(name: "스쿼시", category: "gym", target: "하체", isSelected: false),
        Workout(name: "스쿼시", category: "gym", target: "하체", isSelected: false)
    ]
}

extension Routine {
    static let mockedData: [Routine] = Workout.mockedData.compactMap { Routine(workouts: $0) }
}

extension MyRoutine {
    static let mockedData: MyRoutine = MyRoutine(name: "test", routines: Routine.mockedData)
}

extension WorkoutRoutine {
    static let mockedData: WorkoutRoutine = WorkoutRoutine(name: "",
                                                           startDate: Date(),
                                                           myRoutine: MyRoutine.mockedData)
}
