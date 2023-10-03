//
//  Routine.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/19.
//

import Foundation
import CoreData

struct Routine: Codable, Equatable {
    var workouts: Workouts
    var sets: [Sets]
    var date: Date
    var stopwatch: Double
    
    enum CodingKeys: String, CodingKey {
        case workouts, sets, date, stopwatch
    }
    
    init(workouts: Workouts,
         sets: [Sets] = [Sets()],
         date: Date = .now,
         stopwatch: Double = .zero) {
        self.workouts = workouts
        self.sets = sets
        self.date = date
        self.stopwatch = stopwatch
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        workouts = try container.decode(Workouts.self, forKey: .workouts)
        sets = try container.decode([Sets].self, forKey: .sets)
        date = try container.decode(Date.self, forKey: .date)
        stopwatch = try container.decode(Double.self, forKey: .stopwatch)
    }
}

extension Routine: Identifiable {
    var id: String { workouts.id }
}

typealias Routines = [Routine]
