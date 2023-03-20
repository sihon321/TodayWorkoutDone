//
//  Routine.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/19.
//

import Foundation

struct Sets: Codable {
    var prevWeight: Double
    var weight: Double
    var lap: Int
    var isChecked: Bool
}

struct Routine: Codable, Identifiable {
    var id: UUID
    var excercise: Excercise
    var set: Sets
    var date: Date
    var stopwatch: Date
}
