//
//  WorkoutCategory.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/04/04.
//

import Foundation
import SwiftData

@Model
class WorkoutCategory: Codable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    init(name: String) {
        self.name = name
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}

extension WorkoutCategory: Identifiable {
    var id: String { return name }
}

typealias Categories = [WorkoutCategory]

extension Categories {
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
