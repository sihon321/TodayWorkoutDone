//
//  RoutineDatabase.swift
//  TodayworkoutDone
//
//  Created by ocean on 9/14/24.
//

import Foundation
import SwiftData
import Dependencies

extension DependencyValues {
    var myRoutineData: MyRoutineDatabase {
        get { self[MyRoutineDatabase.self] }
        set { self[MyRoutineDatabase.self] = newValue }
    }
}

struct MyRoutineDatabase {
    var fetchAll: @Sendable () throws -> [MyRoutine]
    var fetch: @Sendable (FetchDescriptor<MyRoutine>) throws -> [MyRoutine]
    var add: @Sendable (MyRoutine) throws -> Void
    var save: @Sendable () throws -> Void
    var delete: @Sendable (MyRoutine) throws -> Void
    
    enum MyRoutineError: Error {
        case add, save, delete
    }
}

extension MyRoutineDatabase: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            do {
                @Dependency(\.databaseService.context) var context
                let routineContext = try context()
                let descriptor = FetchDescriptor<MyRoutine>(sortBy: [SortDescriptor(\.name)])
                
                return try routineContext.fetch(descriptor)
            } catch {
                return []
            }
        },
        fetch: { descriptor in
            do {
                @Dependency(\.databaseService.context) var context
                let routineContext = try context()
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
                throw MyRoutineError.add
            }
        },
        save: {
            do {
                @Dependency(\.databaseService.context) var context
                let routineContext = try context()
                
                try routineContext.save()
            } catch {
                throw MyRoutineError.save
            }
        },
        delete: { model in
            do {
                @Dependency(\.databaseService.context) var context
                let routineContext = try context()
                
                routineContext.delete(model)
                try routineContext.save()
            } catch {
                throw MyRoutineError.delete
            }
        }
    )
}

extension MyRoutineDatabase: TestDependencyKey {
    public static let testValue = Self(
        fetchAll: unimplemented("\(Self.self).fetchAll"),
        fetch: unimplemented("\(Self.self).fetch"),
        add: unimplemented("\(Self.self).add"),
        save: unimplemented("\(Self.self).save"),
        delete: unimplemented("\(Self.self).delete")
    )
}

