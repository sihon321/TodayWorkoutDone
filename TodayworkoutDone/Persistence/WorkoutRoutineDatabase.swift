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
    var save: @Sendable () throws -> Void
    var delete: @Sendable (WorkoutRoutine) throws -> Void
    
    enum WorkoutRoutineError: Error {
        case add
        case save
        case delete
    }
}

extension WorkoutRoutineDatabase: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            do {
                @Dependency(\.databaseService.context) var context
                let routineContext = try context()
                let descriptor = FetchDescriptor<WorkoutRoutine>(sortBy: [SortDescriptor(\.startDate)])
                
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
        save: {
            do {
                @Dependency(\.databaseService.context) var context
                let routineContext = try context()
                
                try routineContext.save()
            } catch {
                throw WorkoutRoutineError.save
            }
        },
        delete: { model in
            do {
                @Dependency(\.databaseService.context) var context
                let routineContext = try context()
                
                routineContext.delete(model)
                try routineContext.save()
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
        save: unimplemented("\(Self.self).save"),
        delete: unimplemented("\(Self.self).delete")
    )
}
