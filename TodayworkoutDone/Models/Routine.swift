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
    
    var prevWeight: Double
    var weight: Double
    var prevLab: Int
    var lab: Int
    var isChecked: Bool
    
    enum CodingKeys: String, CodingKey {
        case prevWeight, weight, prevLab, lab, isChecked
    }
    
    init(prevWeight: Double = .zero,
         weight: Double = .zero,
         prevLab: Int = .zero,
         lab: Int = .zero,
         isChecked: Bool = false) {
        self.prevWeight = prevWeight
        self.weight = weight
        self.prevLab = prevLab
        self.lab = lab
        self.isChecked = isChecked
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        prevWeight = try container.decode(Double.self, forKey: .prevWeight)
        weight = try container.decode(Double.self, forKey: .weight)
        prevLab = try container.decode(Int.self, forKey: .prevLab)
        lab = try container.decode(Int.self, forKey: .lab)
        isChecked = try container.decode(Bool.self, forKey: .isChecked)
    }
}

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

struct MyRoutine: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var routines: [Routine]
    
    init(name: String, routines: [Routine]) {
        self.name = name
        self.routines = routines
    }
}
