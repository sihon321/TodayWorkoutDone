//
//  Routine.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/19.
//

import Foundation
import SwiftData

protocol RoutineData {
    associatedtype WorkoutType
    associatedtype WorkoutSetType
    
    var workout: WorkoutType { get set }
    var sets: [WorkoutSetType] { get set }
    var equipmentType: EquipmentType { get set }
    var averageEndDate: Double? { get set }
    var calories: Double { get set }
    var restTime: Int { get set }
}

struct RoutineState: RoutineData, Codable, Equatable, Identifiable {
    typealias WorkoutType = WorkoutState
    typealias WorkoutSetType = WorkoutSetState
    
    var id = UUID()
    var workout: WorkoutType
    var sets: [WorkoutSetType]
    var equipmentType: EquipmentType
    var averageEndDate: Double?
    var calories: Double = 0.0
    var restTime: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case workouts, sets, equipmentType, endDate, calories, restTime
    }
    
    init(workout: WorkoutState,
         sets: [WorkoutSetState] = [WorkoutSetState()],
         equipmentType: EquipmentType = .barbel,
         averageEndDate: Double? = nil,
         calories: Double = 0.0,
         restTime: Int = 0) {
        self.workout = workout
        self.sets = sets
        self.equipmentType = equipmentType
        self.averageEndDate = averageEndDate
        self.calories = calories
        self.restTime = restTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        workout = try container.decode(WorkoutState.self, forKey: .workouts)
        sets = try container.decode([WorkoutSetState].self, forKey: .sets)
        equipmentType = try container.decode(EquipmentType.self, forKey: .equipmentType)
        averageEndDate = try container.decode(Double?.self, forKey: .endDate)
        calories = try container.decode(Double.self, forKey: .calories)
        restTime = try container.decode(Int.self, forKey: .restTime)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(workout, forKey: .workouts)
        try container.encode(sets, forKey: .sets)
        try container.encode(equipmentType, forKey: .equipmentType)
        try container.encode(averageEndDate, forKey: .endDate)
        try container.encode(calories, forKey: .calories)
        try container.encode(restTime, forKey: .restTime)
    }
}

extension RoutineState {
    init(model: Routine) {
        self.workout = WorkoutState(model: model.workout)
        self.sets = model.sets.compactMap { WorkoutSetState(model: $0) }
        self.equipmentType = model.equipmentType
        self.averageEndDate = model.averageEndDate
        self.calories = model.calories
        self.restTime = model.restTime
    }
    
    func toModel() -> Routine {
        return Routine(
            workout: workout.toModel(),
            sets: sets.compactMap { $0.toModel() },
            equipmentType: equipmentType,
            averageEndDate: averageEndDate,
            calories: calories,
            restTime: restTime
        )
    }
}

extension RoutineState {
    var allTrue: Bool {
        return self.sets.allSatisfy { $0.isChecked }
    }
}

typealias RoutineStates = [RoutineState]

// MARK: - SwiftData

@Model
class Routine: RoutineData, Equatable {
    typealias WorkoutType = Workout
    typealias WorkoutSetType = WorkoutSet
    
    var workout: WorkoutType
    var sets: [WorkoutSetType]
    var equipmentType: EquipmentType
    var averageEndDate: Double?
    var calories: Double = 0.0
    var restTime: Int = 0

    init(workout: Workout,
         sets: [WorkoutSet] = [WorkoutSet()],
         equipmentType: EquipmentType = .barbel,
         averageEndDate: Double? = nil,
         calories: Double = 0.0,
         restTime: Int = 0) {
        self.workout = workout
        self.sets = sets
        self.equipmentType = equipmentType
        self.averageEndDate = averageEndDate
        self.calories = calories
        self.restTime = restTime
    }
}

extension Routine {
    func update(from state: RoutineState) {
        self.sets = state.sets.map { $0.toModel() }
        self.equipmentType = state.equipmentType
        self.averageEndDate = state.averageEndDate
        self.calories = state.calories
        self.restTime = state.restTime
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
