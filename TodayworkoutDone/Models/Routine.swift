//
//  Routine.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/19.
//

import Foundation
import CoreData

struct Sets: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    
    var prevWeight: Double?
    var weight: Double?
    var lap: Int?
    var isChecked: Bool?
    
    enum CodingKeys: String, CodingKey {
        case prevWeight, weight, lap, isChecked
    }
    
    init(prevWeight: Double = .zero,
         weight: Double = .zero,
         lap: Int = .zero,
         isChecked: Bool = false) {
        self.prevWeight = prevWeight
        self.weight = weight
        self.lap = lap
        self.isChecked = isChecked
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        prevWeight = try container.decode(Double.self, forKey: .prevWeight)
        weight = try container.decode(Double.self, forKey: .weight)
        lap = try container.decode(Int.self, forKey: .lap)
        isChecked = try container.decode(Bool.self, forKey: .isChecked)
    }
}

struct Routine: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    
    var workouts: Workouts
    var sets: [Sets]
    var date: Date?
    var stopwatch: Double?
    
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
