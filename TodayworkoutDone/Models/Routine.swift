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
    var endDate: Date? { get set }
}

struct RoutineState: RoutineData, Codable, Equatable, Identifiable {
    typealias WorkoutType = WorkoutState
    typealias WorkoutSetType = WorkoutSetState
    
    var id = UUID()
    var workout: WorkoutType
    var sets: [WorkoutSetType] {
        didSet {
            if allTrue {
                averageEndDate = calculateTimeDifferences(dates: self.sets.compactMap(\.endDate))
                endDate = self.sets.last?.endDate
            }
        }
    }
    var equipmentType: EquipmentType
    var averageEndDate: Double?
    var calories: Double = 0.0
    var restTime: Int = 0
    var endDate: Date?

    var persistentModelID: PersistentIdentifier?
    
    enum CodingKeys: String, CodingKey {
        case workouts, sets, equipmentType, averageEndDate, endDate, calories, restTime
    }
    
    init(workout: WorkoutState,
         sets: [WorkoutSetState] = [],
         equipmentType: EquipmentType = .barbel,
         averageEndDate: Double? = nil,
         calories: Double = 0.0,
         restTime: Int = 0,
         endDate: Date? = nil) {
        self.workout = workout
        self.sets = sets
        self.equipmentType = equipmentType
        self.averageEndDate = averageEndDate
        self.calories = calories
        self.restTime = restTime
        self.endDate = endDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        workout = try container.decode(WorkoutState.self, forKey: .workouts)
        sets = try container.decode([WorkoutSetState].self, forKey: .sets)
        equipmentType = try container.decode(EquipmentType.self, forKey: .equipmentType)
        averageEndDate = try container.decode(Double?.self, forKey: .averageEndDate)
        calories = try container.decode(Double.self, forKey: .calories)
        restTime = try container.decode(Int.self, forKey: .restTime)
        endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(workout, forKey: .workouts)
        try container.encode(sets, forKey: .sets)
        try container.encode(equipmentType, forKey: .equipmentType)
        try container.encode(averageEndDate, forKey: .averageEndDate)
        try container.encode(calories, forKey: .calories)
        try container.encode(restTime, forKey: .restTime)
        try container.encode(endDate, forKey: .endDate)
    }
    
    func calculateTimeDifferences(
        dates: [Date]
    ) -> Double? {
        let intervals = zip(dates, dates.dropFirst()).map { later, earlier in
            let intervalInSeconds = later.timeIntervalSince(earlier)
            return intervalInSeconds
        }
        
        guard !intervals.isEmpty else {
            return nil
        }
        
        let sum = intervals.reduce(0, +)
        return sum / Double(intervals.count)
    }
    
    func getRoutineFromTo() -> (Date, Date)? {
        guard let firstSetEndDate = sets.first?.endDate,
              let lastSetEndDate = sets.last?.endDate,
              let averageEndDate = averageEndDate else {
            return nil
        }
        return (firstSetEndDate - averageEndDate, lastSetEndDate)
    }
}

extension RoutineState {
    init(model: Routine) {
        self.workout = WorkoutState(model: model.workout)
        self.sets = model.sets.sorted(by: {
            $0.order < $1.order
        }).compactMap { WorkoutSetState(model: $0) }
        self.equipmentType = model.equipmentType
        self.averageEndDate = model.averageEndDate
        self.calories = model.calories
        self.restTime = model.restTime
        self.persistentModelID = model.persistentModelID
        self.endDate = model.endDate
    }
    
    func toModel(_ index: Int) -> Routine {
        return Routine(
            index: index,
            workout: workout.toModel(),
            sets: sets.enumerated().compactMap { index, value in value.toModel() },
            equipmentType: equipmentType,
            averageEndDate: averageEndDate,
            calories: calories,
            restTime: restTime,
            endDate: endDate
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
    var endDate: Date?

    init(index: Int,
         workout: WorkoutType,
         sets: [WorkoutSetType] = [],
         equipmentType: EquipmentType = .barbel,
         averageEndDate: Double? = nil,
         calories: Double = 0.0,
         restTime: Int = 0,
         endDate: Date? = nil) {
        self.index = index
        self.workout = workout
        self.sets = sets
        self.equipmentType = equipmentType
        self.averageEndDate = averageEndDate
        self.calories = calories
        self.restTime = restTime
        self.endDate = endDate
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
        self.endDate = state.endDate
        
        // 기존 sets 매핑용 딕셔너리
        var existingSetsDict = Dictionary(uniqueKeysWithValues: self.sets.map { ($0.id, $0) })
        
        // 새롭게 구성될 sets 배열
        var updatedSets: [WorkoutSetType] = []
        
        for (index, newSetState) in state.sets.enumerated() {
            if let id = newSetState.persistentModelID,
                let existing = existingSetsDict.removeValue(forKey: id) {
                // 기존 데이터 업데이트
                existing.update(from: newSetState)
                updatedSets.append(existing)
            } else {
                // 없는 경우 새로 생성
                let newSet = WorkoutSet.create(from: newSetState)
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
            sets: state.sets.enumerated().compactMap({ index, value in WorkoutSet.create(from: value) }),
            equipmentType: state.equipmentType,
            averageEndDate: state.averageEndDate,
            calories: state.calories,
            restTime: state.restTime,
            endDate: state.endDate
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
