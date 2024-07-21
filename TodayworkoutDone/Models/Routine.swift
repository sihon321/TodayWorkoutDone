//
//  Routine.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/19.
//

import Foundation
import CoreData

struct Routine: Codable, Equatable {
    var workouts: Workout
    var sets: [Sets]
    var date: Date
    var stopwatch: Double
    var workotusType: WorkoutsType
    
    enum CodingKeys: String, CodingKey {
        case workouts, sets, date, stopwatch, workotusType
    }
    
    init(workouts: Workout,
         sets: [Sets] = [Sets()],
         date: Date = .now,
         stopwatch: Double = .zero,
         workouts type: WorkoutsType = .barbel) {
        self.workouts = workouts
        self.sets = sets
        self.date = date
        self.stopwatch = stopwatch
        self.workotusType = type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        workouts = try container.decode(Workout.self, forKey: .workouts)
        sets = try container.decode([Sets].self, forKey: .sets)
        date = try container.decode(Date.self, forKey: .date)
        stopwatch = try container.decode(Double.self, forKey: .stopwatch)
        workotusType = try container.decode(WorkoutsType.self, forKey: .workotusType)
    }
}

extension Routine: Identifiable {
    var id: String { workouts.id }
}

typealias Routines = [Routine]
