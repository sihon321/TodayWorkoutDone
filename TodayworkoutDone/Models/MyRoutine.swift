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
    var routines: [RoutineState]
    var isRunning: Bool = false
    var persistentModelID: PersistentIdentifier?
    
    enum CodingKeys: CodingKey {
        case id, name, routines
    }

    init(name: String = "",
         routines: [RoutineState] = [],
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
        routines = try container.decode([RoutineState].self, forKey: .routines)
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
        self.routines = model.routines.compactMap { RoutineState(model: $0) }
        self.isRunning = model.isRunning
        self.persistentModelID = model.persistentModelID
    }
    
    func toModel() -> MyRoutine {
        return MyRoutine(
            name: name,
            routines: routines.compactMap { $0.toModel() },
            isRunning: isRunning
        )
    }
}

// MARK: - SwiftData

@Model
class MyRoutine: MyRoutineData, Equatable {
    typealias RoutineType = Routine
    
    var name: String
    var routines: [Routine]
    var isRunning: Bool = false

    init(name: String = "",
         routines: [Routine] = [],
         isRunning: Bool = false) {
        self.name = name
        self.routines = routines
        self.isRunning = isRunning
    }
}

extension MyRoutine {
    func update(from state: MyRoutineState) {
        name = state.name
        routines = state.routines.compactMap({ $0.toModel() })
        
    }
}
