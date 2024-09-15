//
//  WorkoutRoutineDatabase.swift
//  TodayworkoutDone
//
//  Created by ocean on 9/15/24.
//

import Foundation
import SwiftData
import Dependencies

extension DependencyValues {
    var workoutRoutineData: WorkoutRoutineDatabase {
        get { self[WorkoutRoutineDatabase.self] }
        set { self[WorkoutRoutineDatabase.self] = newValue }
    }
}

struct WorkoutRoutineDatabase {
    var fetchAll: @Sendable () throws -> [WorkoutRoutine]
    var add: @Sendable (WorkoutRoutine) throws -> Void
    var delete: @Sendable (WorkoutRoutine) throws -> Void
    
    enum WorkoutRoutineError: Error {
        case add
        case delete
    }
}

extension WorkoutRoutineDatabase {
    public static let liveValue = Self(
        fetchAll: {
            do {
                @Dependency(\.databaseService.context) var context
                let routineContext = try context()
                let descriptor = FetchDescriptor<WorkoutRoutine>(sortBy: [SortDescriptor(\.date)])
                
                return try routineContext.fetch(descriptor)
            } catch {
                return []
            }
        },
        add: { model in
            do {
                @Dependency(\.databaseService.context) var context
                let routineContext = try context()
                
                routineContext.insert(model)
            } catch {
                throw WorkoutRoutineError.add
            }
        },
        delete: { model in
            do {
                @Dependency(\.databaseService.context) var context
                let routineContext = try context()
                
                routineContext.delete(model)
            } catch {
                throw WorkoutRoutineError.delete
            }
        }
    )
}

extension WorkoutRoutineDatabase: TestDependencyKey {
    public static let testValue = Self(
        fetchAll: unimplemented("\(Self.self).fetchAll"),
        add: unimplemented("\(Self.self).add"),
        delete: unimplemented("\(Self.self).delete")
    )
}


