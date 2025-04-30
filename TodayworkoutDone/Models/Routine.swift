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
    var persistentModelID: PersistentIdentifier?
    
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
        self.sets = model.sets.sorted(by: {
            $0.index < $1.index
        }).compactMap { WorkoutSetState(model: $0) }
        self.equipmentType = model.equipmentType
        self.averageEndDate = model.averageEndDate
        self.calories = model.calories
        self.restTime = model.restTime
        self.persistentModelID = model.persistentModelID
    }
    
    func toModel(_ index: Int) -> Routine {
        return Routine(
            index: index,
            workout: workout.toModel(),
            sets: sets.enumerated().compactMap { index, value in value.toModel(index) },
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
    
    var index: Int
    var workout: WorkoutType
    var sets: [WorkoutSetType]
    var equipmentType: EquipmentType
    var averageEndDate: Double?
    var calories: Double = 0.0
    var restTime: Int = 0

    init(index: Int,
         workout: WorkoutType,
         sets: [WorkoutSetType] = [WorkoutSet()],
         equipmentType: EquipmentType = .barbel,
         averageEndDate: Double? = nil,
         calories: Double = 0.0,
         restTime: Int = 0) {
        self.index = index
        self.workout = workout
        self.sets = sets
        self.equipmentType = equipmentType
        self.averageEndDate = averageEndDate
        self.calories = calories
        self.restTime = restTime
    }
}

extension Routine {
    func update(from state: RoutineState, index: Int) {
        self.index = index
        self.workout.update(from: state.workout)
        self.equipmentType = state.equipmentType
        self.averageEndDate = state.averageEndDate
        self.calories = state.calories
        self.restTime = state.restTime
        
        // 기존 sets 매핑용 딕셔너리
        var existingSetsDict = Dictionary(uniqueKeysWithValues: self.sets.map { ($0.id, $0) })
        
        // 새롭게 구성될 sets 배열
        var updatedSets: [WorkoutSetType] = []
        
        for (index, newSetState) in state.sets.enumerated() {
            if let id = newSetState.persistentModelID,
                let existing = existingSetsDict.removeValue(forKey: id) {
                // 기존 데이터 업데이트
                existing.update(from: newSetState, index: index)
                updatedSets.append(existing)
            } else {
                // 없는 경우 새로 생성
                let newSet = WorkoutSet.create(from: newSetState, index: index)
                updatedSets.append(newSet)
            }
        }
        
        // 남은 건 삭제 대상
        for unused in existingSetsDict.values {
            modelContext?.delete(unused)
        }
        
        // 업데이트된 배열로 교체
        self.sets = updatedSets
    }
    
    static func create(from state: RoutineState, index: Int) -> Routine {
        Routine(
            index: index,
            workout: Workout.create(from: state.workout),
            sets: state.sets.enumerated().compactMap({ index, value in WorkoutSet.create(from: value, index: index) }),
            equipmentType: state.equipmentType,
            averageEndDate: state.averageEndDate,
            calories: state.calories,
            restTime: state.restTime
        )
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
