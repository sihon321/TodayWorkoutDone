//
//  Workouts.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/04.
//

import Foundation
import CoreData

public extension CodingUserInfoKey {
    // Helper property to retrieve the context
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

struct Workout: Codable, Equatable {
    var name: String
    var category: String
    var target: String
    
    enum CodingKeys: String, CodingKey {
        case name, category, target
    }
    
    init(name: String, category: String, target: String) {
        self.name = name
        self.category = category
        self.target = target
    }

    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        target = try container.decode(String.self, forKey: .target)
    }
}

extension Workout: Identifiable {
    var id: String { name }
}
