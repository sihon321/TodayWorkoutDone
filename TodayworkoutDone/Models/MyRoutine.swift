//
//  MyRoutine.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/10/01.
//

import Foundation
import CoreData

struct MyRoutine: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var routines: [Routine]

    init(id: UUID = UUID(), name: String, routines: [Routine]) {
        self.id = id
        self.name = name
        self.routines = routines
    }
}

struct WorkoutRoutine: Codable, Equatable, Identifiable {
    var date: Date
    var routineTime: Int
    var uuid: UUID
    var routines: [Routine]
    
    init(date: Date, routineTime: Int, myRoutine: MyRoutine) {
        self.date = date
        self.uuid = myRoutine.id
        self.routines = myRoutine.routines
        self.routineTime = routineTime
    }
}

extension WorkoutRoutine {
    var id: String { date.description }
}
