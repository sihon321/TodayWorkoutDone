//
//  Workouts.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/04.
//

import Foundation
import SwiftData

public extension CodingUserInfoKey {
    // Helper property to retrieve the context
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

@Model
class Workout: Codable, Equatable {
    var name: String
    var category: String
    var target: String
    var isSelected: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, category, target, isSelected
    }
    
    init(name: String, category: String, target: String, isSelected: Bool) {
        self.name = name
        self.category = category
        self.target = target
        self.isSelected = isSelected
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        target = try container.decode(String.self, forKey: .target)
        isSelected = try container.decode(Bool.self, forKey: .isSelected)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(target, forKey: .target)
        try container.encode(isSelected, forKey: .isSelected)
    }
}

extension Workout: Identifiable {
    var id: String { name }
}
