//
//  WorkoutRoutine.swift
//  TodayworkoutDone
//
//  Created by ocean on 10/4/24.
//

import Foundation
import SwiftData

@Model
class WorkoutRoutine: Codable, Equatable, Identifiable {
    var uuid: UUID
    var name: String
    var startDate: Date
    var endDate: Date?
    var routineTime: Int = 0
    
    @Relationship(deleteRule: .cascade) var routines: [Routine]
    
    enum CodingKeys: CodingKey {
        case uuid, name, startDate, endDate, routineTime, routines
    }
    
    init(name: String, startDate: Date, myRoutine: MyRoutine) {
        self.uuid = UUID()
        self.name = name
        self.startDate = startDate
        self.routines = myRoutine.routines
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(UUID.self, forKey: .uuid)
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date?.self, forKey: .endDate)
        routineTime = try container.decode(Int.self, forKey: .routineTime)
        routines = try container.decode([Routine].self, forKey: .routines)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(name, forKey: .name)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(routineTime, forKey: .routineTime)
        try container.encode(routines, forKey: .routines)
    }
}

extension WorkoutRoutine {
    var id: String { uuid.uuidString }
}

extension WorkoutRoutine {
    var calories: Double {
        routines.map { $0.calories }.reduce(0, +)
    }
}
