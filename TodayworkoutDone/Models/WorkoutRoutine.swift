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
    var date: Date
    var routineTime: Int
    var uuid: UUID
    @Relationship(deleteRule: .cascade) var routines: [Routine]
    
    enum CodingKeys: CodingKey {
        case date, routineTime, uuid, routines
    }
    
    init(date: Date, routineTime: Int, myRoutine: MyRoutine) {
        self.date = date
        self.uuid = UUID()
        self.routineTime = routineTime
        self.routines = myRoutine.routines
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
    var id: String { uuid.uuidString }
}
