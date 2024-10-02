//
//  MyRoutine.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/10/01.
//

import Foundation
import SwiftData

@Model
class MyRoutine: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var routines: [Routine]
    
    enum CodingKeys: CodingKey {
        case id, name, routines
    }

    init(id: UUID = UUID(), name: String, routines: [Routine]) {
        self.id = id
        self.name = name
        self.routines = routines
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        routines = try container.decode([Routine].self, forKey: .routines)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(routines, forKey: .routines)
    }
}
