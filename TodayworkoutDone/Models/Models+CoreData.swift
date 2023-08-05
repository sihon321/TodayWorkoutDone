//
//  Models+CoreData.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/07/17.
//

import Foundation
import CoreData

extension WorkoutsMO: ManagedEntity { }
extension CategoryMO: ManagedEntity { }
extension SetsMO: ManagedEntity { }
extension RoutineMO: ManagedEntity { }
extension MyRoutineMO: ManagedEntity { }

extension Workouts {
    init?(managedObject: WorkoutsMO) {
        guard let name = managedObject.name,
              let category = managedObject.category,
              let target = managedObject.target
            else { return nil }

        self.init(name: name, category: category, target: target)
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> WorkoutsMO? {
        guard let workouts = WorkoutsMO.insertNew(in: context) else {
            return nil
        }
        workouts.name = name
        workouts.target = target
        workouts.category = category
        return workouts
    }
}

extension Category {
    init?(managedObject: CategoryMO) {
        guard let kor = managedObject.kor,
              let en = managedObject.en
        else { return nil }
        
        self.init(kor: kor, en: en)
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> CategoryMO? {
        guard let category = CategoryMO.insertNew(in: context) else {
            return nil
        }
        category.kor = kor
        category.en = en
        return category
    }
}

extension Sets {
    init?(managedObject: SetsMO) {
        self.init(prevWeight: managedObject.prevWeight,
                  weight: managedObject.weight,
                  prevLab: Int(managedObject.prevLab),
                  lab: Int(managedObject.lab),
                  isChecked: managedObject.isChecked)
    }
}

extension Routine {
    init?(managedObject: RoutineMO) {
        guard let workoutsMO = managedObject.workouts,
              let workouts = Workouts(managedObject: workoutsMO),
              let set = managedObject.sets,
              let sets = set.allObjects as? [Sets],
              let date = managedObject.date else {
            return nil
        }
        
        self.init(workouts: workouts,
                  sets: sets,
                  date: date,
                  stopwatch: managedObject.stopwatch)
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> RoutineMO? {
        guard let routine = RoutineMO.insertNew(in: context) else {
            return nil
        }
        let object = WorkoutsMO(context: context)
        object.category = workouts.category
        object.name = workouts.name
        object.category = workouts.category
        
        routine.workouts = object
        routine.sets = NSSet(array: sets)
        routine.date = date
        routine.stopwatch = stopwatch
        
        return routine
    }
}

extension MyRoutine {
    init?(managedObject: MyRoutineMO) {
        guard let set = managedObject.routines,
              let routines = set.allObjects as? Routines else {
            return nil
        }
        
        self.init(routines: routines)
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> MyRoutineMO? {
        guard let myRoutine = MyRoutineMO.insertNew(in: context) else {
            return nil
        }
        
        myRoutine.routines = NSSet(array: routines)
        
        return myRoutine
    }
}

func load<T: Decodable>(_ filename: String, decoder: JSONDecoder = JSONDecoder()) -> T {
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
