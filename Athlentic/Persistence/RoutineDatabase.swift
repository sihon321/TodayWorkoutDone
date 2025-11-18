//
//  RoutineDatabase.swift
//  TodayworkoutDone
//
//  Created by ocean on 5/23/25.
//

import Foundation
import SwiftData
import Dependencies

extension DependencyValues {
    var routineData: RoutineDatabase {
        get { self[RoutineDatabase.self] }
        set { self[RoutineDatabase.self] = newValue }
    }
}

struct RoutineDatabase {
    var fetch: @Sendable (FetchDescriptor<Routine>) throws -> [Routine]
    
    enum RoutineError: Error {
        case fetch
    }
}

extension RoutineDatabase: DependencyKey {
    public static let liveValue = Self(
        fetch: { descriptor in
            do {
                @Dependency(\.databaseService.context) var context
                return try context().fetch(descriptor)
            } catch {
                return []
            }
        }
    )
}
