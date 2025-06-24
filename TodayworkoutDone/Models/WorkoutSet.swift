//
//  WorkoutSet.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/10/01.
//

import Foundation
import SwiftData

protocol WorkoutSetData {
    var order: Int { get }
    var prevWeight: Double { get set }
    var weight: Double { get set }
    var prevReps: Int { get set }
    var reps: Int { get set }
    var isChecked: Bool { get set }
    var endDate: Date? { get set }
    var restTime: Int { get set }
}

struct WorkoutSetState: WorkoutSetData, Codable, Identifiable, Equatable {
    var id: UUID
    var order: Int
    
    var prevWeight: Double
    var weight: Double
    var prevReps: Int
    var reps: Int
    
    var duration: Int
    
    var isChecked: Bool
    var endDate: Date?
    var restTime: Int = 0
    var persistentModelID: PersistentIdentifier?
    
    enum CodingKeys: String, CodingKey {
        case id, order,
             prevWeight, weight, prevReps, reps,
             duration,
             isChecked, endDate, restTime
    }
    
    init(id: UUID = UUID(),
         order: Int,
         prevWeight: Double = .zero,
         weight: Double = .zero,
         prevReps: Int = .zero,
         reps: Int = .zero,
         duration: Int = .zero,
         isChecked: Bool = false) {
        self.id = id
        self.order = order
        self.prevWeight = prevWeight
        self.weight = weight
        self.prevReps = prevReps
        self.reps = reps
        self.duration = duration
        self.isChecked = isChecked
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        order = try container.decode(Int.self, forKey: .order)
        
        prevWeight = try container.decode(Double.self, forKey: .prevWeight)
        weight = try container.decode(Double.self, forKey: .weight)
        prevReps = try container.decode(Int.self, forKey: .prevReps)
        reps = try container.decode(Int.self, forKey: .reps)
        
        duration = try container.decode(Int.self, forKey: .duration)
        
        isChecked = try container.decode(Bool.self, forKey: .isChecked)
        endDate = try container.decode(Date?.self, forKey: .endDate)
        restTime = try container.decode(Int.self, forKey: .restTime)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(order, forKey: .order)
        
        try container.encode(prevWeight, forKey: .prevWeight)
        try container.encode(weight, forKey: .weight)
        try container.encode(prevReps, forKey: .prevReps)
        try container.encode(reps, forKey: .reps)
        
        try container.encode(duration, forKey: .duration)
        
        try container.encode(isChecked, forKey: .isChecked)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(restTime, forKey: .restTime)
    }
    
    static func ==(lhs: WorkoutSetState, rhs: WorkoutSetState) -> Bool {
        return lhs.id == rhs.id
    }
}

extension WorkoutSetState {
    init(model: WorkoutSet) {
        self.id = UUID()
        self.order = model.order
        
        self.prevWeight = model.prevWeight
        self.weight = model.weight
        self.prevReps = model.prevReps
        self.reps = model.reps
        
        self.duration = model.duration
        
        self.isChecked = model.isChecked
        self.endDate = model.endDate
        self.restTime = model.restTime
        
        self.persistentModelID = model.persistentModelID
    }
    
    func toModel() -> WorkoutSet {
        return WorkoutSet(
            order: order,
            prevWeight: prevWeight,
            weight: weight,
            prevReps: prevReps,
            reps: reps,
            duration: duration,
            isChecked: isChecked,
            endDate: endDate,
            restTime: restTime
        )
    }
}

extension Array where Element == WorkoutSetState {
    subscript(uuid: UUID) -> WorkoutSetState? {
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

// MAKR: - SwiftData
@Model
class WorkoutSet: WorkoutSetData, Equatable {
    var order: Int
    
    var prevWeight: Double
    var weight: Double
    var prevReps: Int
    var reps: Int
    
    var duration: Int
    
    var isChecked: Bool
    var endDate: Date?
    var restTime: Int = 0

    init(order: Int = 0,
         prevWeight: Double = .zero,
         weight: Double = .zero,
         prevReps: Int = .zero,
         reps: Int = .zero,
         duration: Int = .zero,
         isChecked: Bool = false,
         endDate: Date? = nil,
         restTime: Int = 0) {
        self.order = order
        self.prevWeight = prevWeight
        self.weight = weight
        self.prevReps = prevReps
        self.reps = reps
        self.duration = duration
        self.isChecked = isChecked
        self.endDate = endDate
        self.restTime = restTime
    }
}

extension WorkoutSet {
    func update(from state: WorkoutSetState) {
        order = state.order
        prevWeight = state.prevWeight
        weight = state.weight
        prevReps = state.prevReps
        reps = state.reps
        duration = state.duration
        isChecked = state.isChecked
        endDate = state.endDate
        restTime = state.restTime
    }
    
    static func create(from state: WorkoutSetState) -> WorkoutSet {
        WorkoutSet(
            order: state.order,
            prevWeight: state.prevWeight,
            weight: state.weight,
            prevReps: state.prevReps,
            reps: state.reps,
            duration: state.duration,
            isChecked: state.isChecked,
            endDate: state.endDate,
            restTime: state.restTime
        )
    }
}

extension Array where Element == WorkoutSet {
    subscript(id: ObjectIdentifier) -> WorkoutSet? {
        get {
            return self.first { $0.id == id }
        }
        set {
            if let index = self.firstIndex(where: { $0.id == id }),
                let newValue = newValue {
                self[index] = newValue
            }
        }
    }
}
