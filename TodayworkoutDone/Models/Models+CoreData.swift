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
extension WorkoutRoutineMO: ManagedEntity { }

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
        self.init(id: managedObject.id ?? UUID(),
                  prevWeight: managedObject.prevWeight,
                  weight: managedObject.weight,
                  prevLab: Int(managedObject.prevLab),
                  lab: Int(managedObject.lab),
                  isChecked: managedObject.isChecked)
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> SetsMO? {
        guard let set = SetsMO.insertNew(in: context) else {
            return nil
        }
        set.id = id
        set.isChecked = isChecked
        set.lab = Int16(lab)
        set.prevLab = Int16(prevLab)
        set.weight = weight
        set.prevWeight = prevWeight
        
        return set
    }
}

extension Routine {
    init?(managedObject: RoutineMO) {
        guard let workoutsMO = managedObject.workouts,
              let workouts = Workouts(managedObject: workoutsMO),
              let set = managedObject.sets,
              let setsMO = set.allObjects as? [SetsMO],
              let date = managedObject.date else {
            return nil
        }
        
        let sets = setsMO.compactMap({ Sets(managedObject: $0) })
        
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

        routine.workouts = workouts.store(in: context)
        routine.sets = NSSet(array: sets.compactMap({ $0.store(in: context) }))
        routine.date = date
        routine.stopwatch = stopwatch
        
        return routine
    }
}

extension MyRoutine {
    init?(managedObject: MyRoutineMO) {
        guard let id = managedObject.id,
              let name = managedObject.name,
              let routinesObject = managedObject.routines,
              let routinesMO = routinesObject.allObjects as? [RoutineMO] else {
            return nil
        }
        let routines = routinesMO.compactMap {
            Routine(managedObject: $0)
        }
        self.init(id: id, name: name, routines: routines)
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext, id: UUID, name: String, workouts: [WorkoutsMO], sets: [[SetsMO]]) -> MyRoutineMO? {
        guard let myRoutine = MyRoutineMO.insertNew(in: context) else {
            return nil
        }

        myRoutine.id = id
        myRoutine.name = name
        myRoutine.routines = NSSet(array: routines.compactMap({ $0.store(in: context) }))
        
        return myRoutine
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext, myRoutineMO: MyRoutineMO) -> MyRoutineMO? {
        var myRoutineMO = myRoutineMO
        
        myRoutineMO.id = id
        myRoutineMO.name = name
        myRoutineMO.routines = NSSet(array: routines.compactMap({ $0.store(in: context) }))
        
        return myRoutineMO
    }
}

extension WorkoutRoutine {
    init?(managedObject: WorkoutRoutineMO) {
        guard let date = managedObject.date,
              let uuid = managedObject.uuid,
              let routinesObject = managedObject.routines,
              let routinesMO = routinesObject.allObjects as? [RoutineMO] else {
            return nil
        }
        let routines = routinesMO.compactMap {
            Routine(managedObject: $0)
        }
        let myRoutine = MyRoutine(id: uuid, name: "", routines: routines)
        self.init(date: date, routineTime: Int(managedObject.routineTime), myRoutine: myRoutine)
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext, date: Date, id: UUID, workouts: [WorkoutsMO], sets: [[SetsMO]]) -> WorkoutRoutineMO? {
        guard let workoutRoutine = WorkoutRoutineMO.insertNew(in: context) else {
            return nil
        }

        workoutRoutine.uuid = id
        workoutRoutine.date = date
        workoutRoutine.routines = NSSet(array: routines.compactMap({ $0.store(in: context) }))
        
        return workoutRoutine
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
