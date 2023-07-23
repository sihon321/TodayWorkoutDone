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

extension Workouts {
    init?(managedObject: WorkoutsMO) {
        guard let name = managedObject.name,
              let category = managedObject.category,
              let target = managedObject.target
            else { return nil }
        
        self.init(name: name, category: category, target: target)
    }
}

//extension Routine {
//    init?(managedObject: RoutineMO) {
//        guard let workouts = managedObject.workouts,
//              let sets = managedObject.sets,
//              let date = managedObject.date,
//              let stopwatch = managedObject.stopwatch
//            else { return nil }
//
//        self.init(workouts: workouts, sets: sets, date: date, stopwatch: stopwatch)
//    }
//}

extension Category {
    init?(managedObject: CategoryMO) {
        guard let kor = managedObject.kor,
              let en = managedObject.en
        else { return nil }
        
        self.init(kor: kor, en: en)
    }
}

extension Sets {
    init?(managedObject: SetsMO) {
        self.init(prevWeight: managedObject.prevWeight,
                  weight: managedObject.weight,
                  lap: Int(managedObject.lap),
                  isChecked: managedObject.isChecked)
    }
}
