//
//  MyRoutine.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/10/01.
//

import Foundation
import SwiftData

protocol MyRoutineData {
    associatedtype RoutineType
    
    var name: String { get set }
    var routines: [RoutineType] { get set }
    var isRunning: Bool { get set }
}

struct MyRoutineState: MyRoutineData, Codable, Equatable, Identifiable {
    typealias RoutineType = RoutineState
    
    var id: UUID
    var name: String
    var routines: [RoutineType]
    var isRunning: Bool = false
    var persistentModelID: PersistentIdentifier?
    
    enum CodingKeys: CodingKey {
        case id, name, routines
    }

    init(name: String = "",
         routines: [RoutineType] = [],
         isRunning: Bool = false) {
        self.id = UUID()
        self.name = name
        self.routines = routines
        self.isRunning = isRunning
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        routines = try container.decode([RoutineType].self, forKey: .routines)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(routines, forKey: .routines)
    }
}

extension MyRoutineState {
    init(model: MyRoutine) {
        self.id = UUID()
        self.name = model.name
        self.routines = model.routines.sorted(by: {
            $0.index < $1.index
        }).compactMap { RoutineState(model: $0) }
        self.isRunning = model.isRunning
        self.persistentModelID = model.persistentModelID
    }
    
    func toModel() -> MyRoutine {
        return MyRoutine(
            name: name,
            routines: routines.enumerated().compactMap { index, value in value.toModel(index) },
            isRunning: isRunning
        )
    }
}

extension MyRoutineState {
    func encodeToData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    static func decodeFromData(_ data: Data) throws -> MyRoutineState {
        return try JSONDecoder().decode(MyRoutineState.self, from: data)
    }
}

// MARK: - SwiftData

@Model
class MyRoutine: MyRoutineData, Equatable {
    typealias RoutineType = Routine
    
    var name: String
    var routines: [RoutineType]
    var isRunning: Bool = false

    init(name: String = "",
         routines: [RoutineType] = [],
         isRunning: Bool = false) {
        self.name = name
        self.routines = routines
        self.isRunning = isRunning
    }
}

extension MyRoutine {
    func update(from state: MyRoutineState) {
        name = state.name
        isRunning = state.isRunning
        
        // 기존 routines 매핑용 딕셔너리
        var existingSetsDict = Dictionary(uniqueKeysWithValues: self.routines.compactMap { ($0.id, $0) })
        
        // 새롭게 구성될 sets 배열
        var updatedRoutines: [RoutineType] = []
        
        for (index, newRoutineState) in state.routines.enumerated() {
            if let id = newRoutineState.persistentModelID,
                let existing = existingSetsDict.removeValue(forKey: id) {
                // 기존 데이터 업데이트
                existing.update(from: newRoutineState, index: index)
                updatedRoutines.append(existing)
            } else {
                // 없는 경우 새로 생성
                let newRoutine = Routine.create(from: newRoutineState, index: index)
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
