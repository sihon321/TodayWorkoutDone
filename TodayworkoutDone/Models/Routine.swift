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
    var date: Date
    var stopwatch: Double
    var workoutsType: WorkoutsType
    
    enum CodingKeys: String, CodingKey {
        case workouts, sets, date, stopwatch, workotusType
    }
    
    init(workouts: Workout,
         sets: [WorkoutSet] = [WorkoutSet()],
         date: Date = .now,
         stopwatch: Double = .zero,
         workouts type: WorkoutsType = .barbel) {
        self.workout = workouts
        self.sets = sets
        self.date = date
        self.stopwatch = stopwatch
        self.workoutsType = type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        workout = try container.decode(Workout.self, forKey: .workouts)
        sets = try container.decode([WorkoutSet].self, forKey: .sets)
        date = try container.decode(Date.self, forKey: .date)
        stopwatch = try container.decode(Double.self, forKey: .stopwatch)
        workoutsType = try container.decode(WorkoutsType.self, forKey: .workotusType)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(workout, forKey: .workouts)
        try container.encode(sets, forKey: .sets)
        try container.encode(date, forKey: .date)
        try container.encode(stopwatch, forKey: .stopwatch)
        try container.encode(workoutsType, forKey: .workotusType)
    }

}

extension Routine {
    static func == (lhs: Routine, rhs: Routine) -> Bool {
        return lhs.id == rhs.id
    }
}

typealias Routines = [Routine]
