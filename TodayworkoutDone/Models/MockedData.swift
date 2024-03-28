//
//  MockedData.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/07/23.
//

import Foundation

extension Category {
    static let mockedData: [Category] = [
        Category(name: "헬스"),
        Category(name: "요가"),
        Category(name: "필라테스")
    ]
}

extension Workouts {
    static let mockedData: [Workouts] = [
        Workouts(name: "스쿼시", category: "gym", target: "하체"),
        Workouts(name: "스쿼시", category: "gym", target: "하체"),
        Workouts(name: "스쿼시", category: "gym", target: "하체")
    ]
}

extension Routine {
    static let mockedData: [Routine] = Workouts.mockedData.compactMap { Routine(workouts: $0) }
}

extension MyRoutine {
    static let mockedData: MyRoutine = MyRoutine(name: "test", routines: Routine.mockedData)
}

extension WorkoutRoutine {
    static let mockedData: WorkoutRoutine = WorkoutRoutine(date: Date(), routineTime: 0, myRoutine: MyRoutine.mockedData)
}
