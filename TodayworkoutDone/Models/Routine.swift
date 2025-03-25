//
//  Routine.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/19.
//

import Foundation
import SwiftData

class Routine: Codable, Equatable, Identifiable {
    let id = UUID()
    var workout: Workout
    var sets: [WorkoutSet]
    var workoutsType: WorkoutsType
    var averageEndDate: Double?
    var calories: Double = 0.0
    var restTime: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case workouts, sets, workotusType, endDate, calories, restTime
    }
    
    init(workouts: Workout,
         sets: [WorkoutSet] = [WorkoutSet()],
         workouts type: WorkoutsType = .barbel) {
        self.workout = workouts
        self.sets = sets
        self.workoutsType = type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        workout = try container.decode(Workout.self, forKey: .workouts)
        sets = try container.decode([WorkoutSet].self, forKey: .sets)
        workoutsType = try container.decode(WorkoutsType.self, forKey: .workotusType)
        averageEndDate = try container.decode(Double?.self, forKey: .endDate)
        calories = try container.decode(Double.self, forKey: .calories)
        restTime = try container.decode(Int.self, forKey: .restTime)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(workout, forKey: .workouts)
        try container.encode(sets, forKey: .sets)
        try container.encode(workoutsType, forKey: .workotusType)
        try container.encode(averageEndDate, forKey: .endDate)
        try container.encode(calories, forKey: .calories)
        try container.encode(restTime, forKey: .restTime)
    }
}

extension Routine {
    var allTrue: Bool {
        return self.sets.allSatisfy { $0.isChecked }
    }
}

extension Routine {
    static func == (lhs: Routine, rhs: Routine) -> Bool {
        return lhs.id == rhs.id
    }
}

typealias Routines = [Routine]


