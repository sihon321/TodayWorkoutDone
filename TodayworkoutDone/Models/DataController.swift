//
//  ModelData.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/04.
//

import Foundation
import Combine
import CoreData

final class DataController: ObservableObject {
    @Published var exercises: [Workouts] = []
    let container = NSPersistentContainer(name: "ModelData")
    
    init() {
        container.loadPersistentStores { [weak self] description, error in
            guard let `self` = self else { return }
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            } else {
                self.parse()
            }
        }
    }
    
    func parse() {
        do {
            guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                fatalError("Failed to retrieve context")
            }

            let managedObjectContext = container.viewContext
            let decoder = JSONDecoder()
            decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
            let jsonData = load("workouts.json")
            _ = try decoder.decode([Workouts].self, from: jsonData)
            try managedObjectContext.save()

        } catch let error {
            print(error)
        }
    }
}

func load(_ filename: String) -> Data {
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

    return data
}
