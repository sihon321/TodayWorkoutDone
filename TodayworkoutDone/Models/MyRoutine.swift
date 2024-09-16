//
//  MyRoutine.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/10/01.
//

import Foundation
import SwiftData

@Model
class MyRoutine: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var routines: [Routine]
    
    enum CodingKeys: CodingKey {
        case id, name, routines
    }

    init(id: UUID = UUID(), name: String, routines: [Routine]) {
        self.id = id
        self.name = name
        self.routines = routines
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        routines = try container.decode([Routine].self, forKey: .routines)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(routines, forKey: .routines)
    }
}

@Model
class WorkoutRoutine: Codable, Equatable, Identifiable {
    var date: Date
    var routineTime: Int
    var uuid: UUID
    var routines: [Routine]
    
    enum CodingKeys: CodingKey {
        case date, routineTime, uuid, routines
    }
    
    init(date: Date, routineTime: Int, myRoutine: MyRoutine) {
        self.date = date
        self.uuid = myRoutine.id
        self.routines = myRoutine.routines
        self.routineTime = routineTime
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        routineTime = try container.decode(Int.self, forKey: .routineTime)
        uuid = try container.decode(UUID.self, forKey: .uuid)
        routines = try container.decode([Routine].self, forKey: .routines)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(routineTime, forKey: .routineTime)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(routines, forKey: .routines)
    }
}

extension WorkoutRoutine {
    var id: String { date.description }
}
