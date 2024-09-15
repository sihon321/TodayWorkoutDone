//
//  WorkoutDatabase.swift
//  TodayworkoutDone
//
//  Created by ocean on 9/14/24.
//

import Foundation
import SwiftData
import Dependencies

extension DependencyValues {
    var workoutData: WorkoutDatabase {
        get { self[WorkoutDatabase.self] }
        set { self[WorkoutDatabase.self] = newValue }
    }
}

struct WorkoutDatabase {
    var fetchAll: @Sendable () throws -> [Workout]
    var addAll: @Sendable ([Workout]) throws -> Void
    
    enum WorkoutError: Error {
        case addAll
    }
}

extension WorkoutDatabase {
    public static let liveValue = Self(
        fetchAll: {
            do {
                @Dependency(\.databaseService.context) var context
                let workoutContext = try context()
                let descriptor = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\.name)])
                
                return try workoutContext.fetch(descriptor)
            } catch {
                return []
            }
        },
        addAll: { models in
            do {
                @Dependency(\.databaseService.context) var context
                let workoutContext = try context()
                
                for model in models {
                    workoutContext.insert(model)
                }
            } catch {
                throw WorkoutError.addAll
            }
        }
    )
}

extension WorkoutDatabase: TestDependencyKey {
    public static let testValue = Self(
        fetchAll: unimplemented("\(Self.self).fetchAll"),
        addAll: unimplemented("\(Self.self).addAll")
    )
}
