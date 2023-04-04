//
//  Routine.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/19.
//

import Foundation
import CoreData

@objc(Sets)
struct Sets: NSManagedObject, Codable {
    @NSManaged var prevWeight: Double?
    @NSManaged var weight: Double?
    @NSManaged var lap: Int?
    @NSManaged var isChecked: Bool?
    
    enum CodingKeys: String, CodingKey {
        case prevWeight, weight, lap, isChecked
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Excercise",
                                                    in: managedObjectContext) else {
            fatalError("Failed to decode Excercise")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        prevWeight = try container.decode(Double.self, forKey: .prevWeight)
        weight = try container.decode(Double.self, forKey: .weight)
        lap = try container.decode(Int.self, forKey: .lap)
        isChecked = try container.decode(Bool.self, forKey: .isChecked)
    }
}

@objc(Routine)
struct Routine: NSManagedObject, Codable, Identifiable {
    var id: UUID = UUID()
    @NSManaged var excercise: Excercise?
    @NSManaged var sets: [Sets]?
    @NSManaged var date: Date?
    @NSManaged var stopwatch: Date?
    
    enum CodingKeys: String, CodingKey {
        case excercise, sets, date, stopwatch
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Excercise",
                                                    in: managedObjectContext) else {
            fatalError("Failed to decode Excercise")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        excercise = try container.decode(Excercise.self, forKey: .excercise)
        sets = try container.decode([Sets].self, forKey: .sets)
        date = try container.decode(Date.self, forKey: .date)
        stopwatch = try container.decode(Date.self, forKey: .stopwatch)
    }
}
