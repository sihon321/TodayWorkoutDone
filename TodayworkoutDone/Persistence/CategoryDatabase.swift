//
//  CategoryDatabase.swift
//  TodayworkoutDone
//
//  Created by ocean on 9/15/24.
//

import Foundation
import SwiftData
import Dependencies

extension DependencyValues {
    var categoryData: CategoryDatabase {
        get { self[CategoryDatabase.self] }
        set { self[CategoryDatabase.self] = newValue }
    }
}

struct CategoryDatabase {
    var fetchAll: @Sendable () throws -> [Category]
    var add: @Sendable (Category) throws -> Void
    var delete: @Sendable (Category) throws -> Void
    
    enum CategoryError: Error {
        case add
        case delete
    }
}

extension CategoryDatabase {
    public static let liveValue = Self(
        fetchAll: {
            do {
                @Dependency(\.databaseService.context) var context
                let categoryContext = try context()
                let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
                
                return try categoryContext.fetch(descriptor)
            } catch {
                return []
            }
        },
        add: { model in
            do {
                @Dependency(\.databaseService.context) var context
                let categoryContext = try context()
                
                categoryContext.insert(model)
            } catch {
                throw CategoryError.add
            }
        },
        delete: { model in
            do {
                @Dependency(\.databaseService.context) var context
                let categoryContext = try context()
                
                categoryContext.delete(model)
            } catch {
                throw CategoryError.delete
            }
        }
    )
}

extension CategoryDatabase: TestDependencyKey {
    public static let testValue = Self(
        fetchAll: unimplemented("\(Self.self).fetchAll"),
        add: unimplemented("\(Self.self).add"),
        delete: unimplemented("\(Self.self).delete")
    )
}



