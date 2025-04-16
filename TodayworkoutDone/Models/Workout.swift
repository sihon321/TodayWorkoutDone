//
//  Workouts.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/04.
//

import Foundation
import SwiftData

protocol WorkoutData {
    var name: String { get set }
    var category: String { get set }
    var target: String { get set }
    var isSelected: Bool { get set }
}

struct WorkoutState: WorkoutData, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var category: String
    var target: String
    var isSelected: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, category, target, isSelected
    }
    
    init(name: String, category: String, target: String, isSelected: Bool) {
        self.name = name
        self.category = category
        self.target = target
        self.isSelected = isSelected
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        target = try container.decode(String.self, forKey: .target)
        isSelected = try container.decode(Bool.self, forKey: .isSelected)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(target, forKey: .target)
        try container.encode(isSelected, forKey: .isSelected)
    }
}

extension WorkoutState {
    init(model: Workout) {
        self.name = model.name
        self.category = model.category
        self.target = model.target
        self.isSelected = model.isSelected
    }
    
    func toModel() -> Workout {
        return Workout(
            name: name,
            category: category,
            target: target,
            isSelected: isSelected
        )
    }
}

extension Array where Element == WorkoutState {
    var allTrue: Bool {
        return self.allSatisfy { $0.isSelected }
    }
}

// MARK: - SwiftData

@Model
class Workout: WorkoutData, Equatable {
    var name: String
    var category: String
    var target: String
    var isSelected: Bool

    init(name: String, category: String, target: String, isSelected: Bool) {
        self.name = name
        self.category = category
        self.target = target
        self.isSelected = isSelected
    }
}

extension Workout {
    func update(from state: WorkoutState) {
        name = state.name
        category = state.category
        target = state.target
        isSelected = state.isSelected
    }
    
    static func create(from state: WorkoutState) -> Workout {
        Workout(
            name: state.name,
            category: state.category,
            target: state.target,
            isSelected: state.isSelected
        )
    }
}

extension Array where Element == Workout {
    var allTrue: Bool {
        return self.allSatisfy { $0.isSelected }
    }
}
