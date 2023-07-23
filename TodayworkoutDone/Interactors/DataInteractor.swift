//
//  DataInteractor.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/07/11.
//

import Foundation
import Combine
import CoreData

protocol DataInteractor {
    var persistentContainer: NSPersistentContainer { get }
}

struct WorkoutDataInteractor: DataInteractor {
    let appState: Store<AppState>
    var persistentContainer = NSPersistentContainer(name: "ModelData")
    
    init(appState: Store<AppState>) {
        self.appState = appState
        
        loadPersistentStores()
    }
    
    private func loadPersistentStores() {
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            } else {
                self.parse()
            }
        }
    }
    
    private func parse() {
        do {
            guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                fatalError("Failed to retrieve context")
            }
            
            let managedObjectContext = persistentContainer.viewContext
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
            
            let categories: [Category] = load("category.json", decoder: decoder)
            let categoryFetchRequest = NSFetchRequest<Category>(entityName: "Category")
            var categoryResult: [Category] = []
            do {
                let fetchResult = try managedObjectContext.fetch(categoryFetchRequest)
                categoryResult = fetchResult.filter { !categories.contains($0) }
            } catch {
                print(error)
            }
            if !categoryResult.isEmpty {
                _ = try decoder.decode([Category].self, from: categoryResult.jsonData())
                try managedObjectContext.save()
            }
            
            let workouts: [Workouts] = load("workouts.json", decoder: decoder)
            let fetchRequest = NSFetchRequest<Workouts>(entityName: "Workouts")
            var result: [Workouts] = []
            
            do {
                let fetchResult = try managedObjectContext.fetch(fetchRequest)
                result = fetchResult.filter { !workouts.contains($0) }
            } catch {
                print(error)
            }
            
            if !result.isEmpty {
                _ = try decoder.decode([Workouts].self, from: result.jsonData())
                try managedObjectContext.save()
            }
        } catch let error {
            print(error)
        }
    }
    
    private func load<T: Decodable>(_ filename: String, decoder: JSONDecoder = JSONDecoder()) -> T {
        let data: Data

        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }

        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
}

struct StubWorkoutDataInteractor: DataInteractor {
    var persistentContainer = NSPersistentContainer(name: "ModelData")
}
