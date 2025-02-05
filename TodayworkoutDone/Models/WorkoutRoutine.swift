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
    var startDate: Date
    var endDate: Date?
    var calories: Double = 0.0
    var routineTime: Int = 0
    
    @Relationship(deleteRule: .cascade) var routines: [Routine]
    
    enum CodingKeys: CodingKey {
        case uuid, startDate, endDate, calories, routineTime, routines
    }
    
    init(startDate: Date, myRoutine: MyRoutine) {
        self.uuid = UUID()
        self.startDate = startDate
        self.routines = myRoutine.routines
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(UUID.self, forKey: .uuid)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date?.self, forKey: .endDate)
        calories = try container.decode(Double.self, forKey: .calories)
        routineTime = try container.decode(Int.self, forKey: .routineTime)
        routines = try container.decode([Routine].self, forKey: .routines)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(calories, forKey: .calories)
        try container.encode(routineTime, forKey: .routineTime)
        try container.encode(routines, forKey: .routines)
    }
}

extension WorkoutRoutine {
    var id: String { uuid.uuidString }
}
