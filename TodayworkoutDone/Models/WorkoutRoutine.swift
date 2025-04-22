//
//  WorkoutRoutine.swift
//  TodayworkoutDone
//
//  Created by ocean on 10/4/24.
//

import Foundation
import SwiftData

protocol WorkoutRoutineData {
    associatedtype RoutineType
    
    var name: String { get set }
    var startDate: Date { get set }
    var endDate: Date? { get set }
    var routineTime: Int { get set }
    var routines: [RoutineType] { get set }
}

struct WorkoutRoutineState: WorkoutRoutineData, Codable, Equatable, Identifiable {
    typealias RoutineType = RoutineState
    
    var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date?
    var routineTime: Int = 0
    var routines: [RoutineState]
    var persistentModelID: PersistentIdentifier?
    
    enum CodingKeys: CodingKey {
        case id, name, startDate, endDate, routineTime, routines
    }
    
    init(name: String,
         startDate: Date,
         endDate: Date? = nil,
         routineTime: Int = 0,
         routines: [RoutineState]) {
        self.id = UUID()
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.routineTime = routineTime
        self.routines = routines
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date?.self, forKey: .endDate)
        routineTime = try container.decode(Int.self, forKey: .routineTime)
        routines = try container.decode([RoutineState].self, forKey: .routines)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(routineTime, forKey: .routineTime)
        try container.encode(routines, forKey: .routines)
    }
}

extension WorkoutRoutineState {
    init(model: WorkoutRoutine) {
        self.id = UUID()
        self.name = model.name
        self.startDate = model.startDate
        self.endDate = model.endDate
        self.routineTime = model.routineTime
        self.routines = model.routines.compactMap { RoutineState(model: $0) }
        self.persistentModelID = model.persistentModelID
    }
    
    func toModel() -> WorkoutRoutine {
        WorkoutRoutine(
            name: name,
            startDate: startDate,
            endDate: endDate,
            routineTime: routineTime,
            routines: routines.compactMap { $0.toModel() }
        )
    }
}

extension WorkoutRoutineState {
    var calories: Double {
        routines.map { $0.calories }.reduce(0, +)
    }
}

// MARK: - SwiftData

@Model
class WorkoutRoutine: WorkoutRoutineData, Equatable {
    typealias RoutineType = Routine
    
    var name: String
    var startDate: Date
    var endDate: Date?
    var routineTime: Int = 0
    @Relationship(deleteRule: .cascade) var routines: [Routine]

    init(name: String,
         startDate: Date,
         endDate: Date? = nil,
         routineTime: Int = 0,
         routines: [Routine] = []) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.routineTime = routineTime
        self.routines = routines
    }
}

extension WorkoutRoutine {
    func update(from state: WorkoutRoutineState) {
        self.name = state.name
        self.startDate = state.startDate
        self.endDate = state.endDate
        // 기존 routines 매핑용 딕셔너리
        var existingSetsDict = Dictionary(uniqueKeysWithValues: self.routines.compactMap { ($0.id, $0) })
        
        // 새롭게 구성될 sets 배열
        var updatedRoutines: [RoutineType] = []
        
        for newRoutineState in state.routines {
            if let id = newRoutineState.persistentModelID,
                let existing = existingSetsDict.removeValue(forKey: id) {
                // 기존 데이터 업데이트
                existing.update(from: newRoutineState)
                updatedRoutines.append(existing)
            } else {
                // 없는 경우 새로 생성
                let newRoutine = Routine.create(from: newRoutineState)
                updatedRoutines.append(newRoutine)
            }
        }
        
        // 남은 건 삭제 대상
        for unused in existingSetsDict.values {
            modelContext?.delete(unused)
        }
        
        // 업데이트된 배열로 교체
        self.routines = updatedRoutines
    }
}


extension WorkoutRoutine {
    var calories: Double {
        routines.map { $0.calories }.reduce(0, +)
    }
}
