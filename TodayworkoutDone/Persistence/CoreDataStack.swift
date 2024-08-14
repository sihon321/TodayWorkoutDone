//
//  CoreDataStack.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/07/17.
//

import SwiftData
import ComposableArchitecture

extension DependencyValues {
    var databaseService: Database {
        get { self[Database.self] }
        set { self[Database.self] = newValue }
    }
}

struct Database {
    var context: () throws -> ModelContext
}

extension Database: DependencyKey {
    @MainActor
    public static let liveValue = Self(
        context: { appContext }
    )
}

@MainActor
let appContext: ModelContext = {
    let container = SwiftDataConfigurationProvider.shared.container
    let context = ModelContext(container)
    return context
}()

public class SwiftDataConfigurationProvider {
    
    public static let shared = SwiftDataConfigurationProvider(
        isStoredInMemoryOnly: false,
        autosaveEnabled: true
    )
    
    private var isStoredInMemoryOnly: Bool
    private var autosaveEnabled: Bool
    
    private init(isStoredInMemoryOnly: Bool, autosaveEnabled: Bool) {
        self.isStoredInMemoryOnly = isStoredInMemoryOnly
        self.autosaveEnabled = autosaveEnabled
    }
    
    @MainActor
    public lazy var container: ModelContainer = {
        let schema = Schema(
            [
                Workout.self,
                Routine.self,
                Category.self,
                MyRoutine.self,
                Sets.self
            ]
        )
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )
        
        let container = try! ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        container.mainContext.autosaveEnabled = autosaveEnabled
        return container
    }()
}
