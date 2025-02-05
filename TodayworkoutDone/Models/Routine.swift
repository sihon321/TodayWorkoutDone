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
    var endDate: Date?
    var workoutTime: Double?
    
    enum CodingKeys: String, CodingKey {
        case workouts, sets, workotusType, endDate, workoutTime
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
        endDate = try container.decode(Date?.self, forKey: .endDate)
        workoutTime = try container.decode(Double?.self, forKey: .workoutTime)
        
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(workout, forKey: .workouts)
        try container.encode(sets, forKey: .sets)
        try container.encode(workoutsType, forKey: .workotusType)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(workoutTime, forKey: .workoutTime)
    }

}

extension Routine {
    static func == (lhs: Routine, rhs: Routine) -> Bool {
        return lhs.id == rhs.id
    }
}

typealias Routines = [Routine]
