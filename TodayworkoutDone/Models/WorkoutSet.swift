//
//  WorkoutSet.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/10/01.
//

import Foundation
import SwiftData

@Model
class WorkoutSet: Codable, Identifiable, Equatable {
    var id: UUID
    var prevWeight: Double
    var weight: Double
    var prevReps: Int
    var reps: Int
    var isChecked: Bool
    var endDate: Date?
    var restTime: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id, prevWeight, weight, prevReps, reps, isChecked, endDate, restTime
    }
    
    init(id: UUID = UUID(),
         prevWeight: Double = .zero,
         weight: Double = .zero,
         prevReps: Int = .zero,
         reps: Int = .zero,
         isChecked: Bool = false) {
        self.id = id
        self.prevWeight = prevWeight
        self.weight = weight
        self.prevReps = prevReps
        self.reps = reps
        self.isChecked = isChecked
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        prevWeight = try container.decode(Double.self, forKey: .prevWeight)
        weight = try container.decode(Double.self, forKey: .weight)
        prevReps = try container.decode(Int.self, forKey: .prevReps)
        reps = try container.decode(Int.self, forKey: .reps)
        isChecked = try container.decode(Bool.self, forKey: .isChecked)
        endDate = try container.decode(Date?.self, forKey: .endDate)
        restTime = try container.decode(Int.self, forKey: .restTime)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(prevWeight, forKey: .prevWeight)
        try container.encode(weight, forKey: .weight)
        try container.encode(prevReps, forKey: .prevReps)
        try container.encode(reps, forKey: .reps)
        try container.encode(isChecked, forKey: .isChecked)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(restTime, forKey: .restTime)
    }
    
    static func ==(lhs: WorkoutSet, rhs: WorkoutSet) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Array where Element == WorkoutSet {
    subscript(uuid: UUID) -> WorkoutSet? {
        get {
            return self.first { $0.id == uuid }
        }
        set {
            if let index = self.firstIndex(where: { $0.id == uuid }),
                let newValue = newValue {
                self[index] = newValue
            }
        }
    }
}
